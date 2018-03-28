//
//  Session.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit

protocol SessionType {
    func resolve<T>() -> T
}

final class Session: SessionType {

    private let container = Container()
    var router: SessionRouterType?

    init() {
        container.register(AuthTokenServiceProtocol.self) { [weak self] _ in
            OAuth2Service(config: .github, scopes: Constants.githubScopes, presenter: { [weak self] (view) in
                self?.router?.presentModally(view)
            })
        }
        container.register(GithubServiceProtocol.self) {
            guard let baseUrl = URL(string: Constants.githubApiBaseUrl) else {
                fatalError("github base url is incorrect")
            }
            let authService: AuthTokenServiceProtocol = $0.resolve()
            return GithubService(baseUrl: baseUrl, authService: authService)
        }
    }

    func resolve<T>() -> T {
        return container.resolve()
    }

}
