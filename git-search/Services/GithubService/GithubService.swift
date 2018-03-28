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
        static let searchRequestFormat = "{\"query\": \"query { repositoryOwner(login: \\\"%@\\\") { id repositories(first: %d%@) { pageInfo { endCursor hasNextPage hasPreviousPage startCursor } totalCount nodes { id name languages(first: 100) { nodes { id name } } stargazers { totalCount } } } } }\"}"
    }

    private let webService: HttpJsonService<HttpDataFilter>
    private let authService: AuthTokenServiceProtocol

    init(baseUrl: URL, authService: AuthTokenServiceProtocol) {
        self.authService = authService
        webService = HttpJsonService(baseUrl: baseUrl)
    }

}

extension GithubService: GithubServiceProtocol {

    func searchRepository(by owner: String) -> SignalProducer<[RepositoryType], ServiceError> {
        return authService.authToken().flatMap(.latest) { [weak self] token -> SignalProducer<[RepositoryType], ServiceError> in
            guard let strongSelf = self else {
                    return .empty
            }
            let requestData = strongSelf.searchRequest(owner: owner, pageSize: Consts.pageSize).data(using: .utf8)
            let headerParams = [HTTP.HeaderKey.authorization: "Bearer \(token)"]
            let filter = HttpDataFilter(path: Consts.apiPath, method: .post, headerParams: headerParams, body: requestData)
            return strongSelf.webService.request(filter: filter).map { rawRepos -> [RepositoryType] in
                print(rawRepos)
//                JSONDecoder().decode(<#T##type: Decodable.Protocol##Decodable.Protocol#>, from: <#T##Data#>)
                return []
            }
        }
    }

}

// MARK: - Private

private extension GithubService {

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
