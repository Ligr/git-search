//
//  HttpService.swift
//  DataKit
//
//  Created by Alex on 2/11/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import ReactiveSwift

enum HTTP {

    struct ContentType {
        static let formUrlencoded = "application/x-www-form-urlencoded"
        static let json = "application/json"
    }

    struct Accept {
        static let json = "application/json"
    }

    struct HeaderKey {
        static let contentType = "Content-Type"
        static let accept = "Accept"
        static let authorization = "Authorization"
    }

}

struct HttpResponse<T> {
    let data: T
    let response: URLResponse
}

final class HttpService<FilterType: HttpDataFilterProtocol>: ServiceProtocol {

    typealias ResultType = HttpResponse<Data>

    private let baseUrl: URL
    private let urlSession: URLSession
    private lazy var requestFactory: SignalProducerCachedFactory<FilterType, ResultType, ServiceError> = {
        return SignalProducerCachedFactory(factory: { [unowned self] (filter) -> SignalProducer<ResultType, ServiceError> in
            return self.dataTask(with: filter)
        })
    }()

    convenience init?(baseUrl: String) {
        guard let url = URL(string: baseUrl) else {
            return nil
        }
        self.init(baseUrl: url)
    }

    init(baseUrl: URL) {
        self.baseUrl = baseUrl
        let urlSessionConfig = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: urlSessionConfig)
    }

    func request(filter: FilterType) -> SignalProducer<ResultType, ServiceError> {
        return requestFactory.producer(for: filter)
    }

}

// MARK: - Private

private extension HttpService {

    func dataTask(with filter: FilterType) -> SignalProducer<ResultType, ServiceError> {
        let request = urlRequest(for: filter)
        return SignalProducer { [weak self] observer, lifetime in
            guard let strongSelf = self else {
                observer.sendInterrupted()
                return
            }
            let task = strongSelf.urlSession.dataTask(with: request) { data, response, error in
                if let data = data, let response = response {
                    observer.send(value: HttpResponse(data: data, response: response))
                    observer.sendCompleted()
                } else {
                    observer.send(error: .requestFailed(error))
                }
            }
            lifetime.observeEnded(task.cancel)
            task.resume()
        }
    }

    func urlRequest(for filter: FilterType) -> URLRequest {
        let url = self.url(for: filter)
        var headerParams = filter.headerParams

        var request = URLRequest(url: url)
        switch filter.method {
        case .get:
            request.httpMethod = "GET"
        case .post:
            if let query = urlQuery(for: filter) {
                headerParams[HTTP.HeaderKey.contentType] = HTTP.ContentType.formUrlencoded
                request.httpBody = query.data(using: .utf8)
            } else {
                request.httpBody = filter.body
            }
            request.httpMethod = "POST"
        }
        for (headerKey, headerValue) in headerParams {
            request.setValue(headerValue, forHTTPHeaderField: headerKey)
        }
        return request
    }

    func url(for filter: FilterType) -> URL {
        var url = baseUrl.appendingPathComponent(filter.path)
        switch filter.method {
        case .get:
            if let query = urlQuery(for: filter) {
                url.appendPathExtension("?" + query)
            }
        case .post:
            break
        }
        return url
    }

    func urlQuery(for filter: FilterType) -> String? {
        let params = filter.requestParams.map({ $0.0 + "=" + $0.1 }).joined(separator: "&")
        if params.count > 0 {
            return params
        }
        return nil
    }

}
