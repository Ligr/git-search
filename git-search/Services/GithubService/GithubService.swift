//
//  GithubService.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

final class GithubService {

    private struct Consts {
        static let apiPath = "graphql"
        static let pageSize = 100
        static let pageCursorFormat = ", after:\\\"%@\\\""
        static let searchRequestFormat = "{\"query\": \"query { repositoryOwner(login: \\\"%@\\\") { id repositories(first: %d, orderBy: {direction: DESC, field: STARGAZERS}%@) { pageInfo { endCursor hasNextPage } totalCount nodes { id name languages(first: 100) { nodes { id name } } stargazers { totalCount } } } } }\"}"
    }

    private final class GithubFilter: HttpDataFilter, DecodableDataFilterProtocol {

        typealias DecodableType = RepositoryResponse

    }

    private let webService: HttpDecodableService<GithubFilter>
    private let authService: AuthTokenServiceProtocol

    init(baseUrl: URL, authService: AuthTokenServiceProtocol) {
        self.authService = authService
        webService = HttpDecodableService(baseUrl: baseUrl)
    }

}

extension GithubService: GithubServiceProtocol {

    func searchRepository(by owner: String) -> SignalProducer<[RepositoryType], ServiceError> {
        return searchAllRepositories(by: owner, pageCursor: nil)
    }

}

// MARK: - Private

private extension GithubService {

    func searchAllRepositories(by owner: String, pageCursor: String?) -> SignalProducer<[RepositoryType], ServiceError> {
        return repositories(by: owner, pageCursor: pageCursor).flatMap(.latest) { [weak self] repositories -> SignalProducer<[RepositoryType], ServiceError> in
            guard let strongSelf = self else {
                return .empty
            }
            if repositories.pageInfo.hasNextPage {
                return strongSelf.searchAllRepositories(by: owner, pageCursor: repositories.pageInfo.endCursor).reduce(repositories.repositories, { (prevRepositories, newRepositories) -> [RepositoryType] in
                    return prevRepositories + newRepositories
                })
            }
            return SignalProducer(value: repositories.repositories)
        }
    }

    func repositories(by owner: String, pageCursor: String?) -> SignalProducer<RepositoryResponseType, ServiceError> {
        return authService.authToken().observe(on: QueueScheduler()).flatMap(.latest) { [weak self] token -> SignalProducer<RepositoryResponseType, ServiceError> in
            guard let strongSelf = self else {
                return .empty
            }
            let requestData = strongSelf.searchRequest(owner: owner, pageSize: Consts.pageSize, pageCursor: pageCursor).data(using: .utf8)
            let headerParams = [HTTP.HeaderKey.authorization: "Bearer \(token)"]
            let filter = GithubFilter(path: Consts.apiPath, method: .post, headerParams: headerParams, body: requestData)
            return strongSelf.webService.request(filter: filter).map { response -> RepositoryResponseType in
                return response.data
            }
        }
    }

    func searchRequest(owner: String, pageSize: Int, pageCursor: String? = nil) -> String {
        let cursor: String
        if let pageCursor = pageCursor, pageCursor.isEmpty == false {
            cursor = String(format: Consts.pageCursorFormat, pageCursor)
        } else {
            cursor = ""
        }
        let request = String(format: Consts.searchRequestFormat, owner, pageSize, cursor)
        return request
    }

}
