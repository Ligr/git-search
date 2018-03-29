//
//  OAuthService.swift
//  git-search
//
//  Created by Alex on 3/26/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import OAuthSwift

struct OAuth2Filter: DataFilterProtocol {

    var identifier: String {
        return scopes.joined(separator: "")
    }
    let scopes: [String]

}

class OAuth2Service {

    private struct Consts {
        static let callbackUrl = "https://oauth2.login/success"
    }

    private let presenter: (UIViewController) -> Void
    private let oauth2Config: OAuth2Swift
    private let scopes: [String]

    init(config: OAuth2Swift, scopes: [String], presenter: @escaping (UIViewController) -> Void) {
        self.presenter = presenter
        self.oauth2Config = config
        self.scopes = scopes
    }

}

extension OAuth2Service: AuthTokenServiceProtocol {

    func authToken() -> SignalProducer<String, ServiceError> {
        let filter = OAuth2Filter(scopes: scopes)
        return request(filter: filter).map {
            $0.oauthToken
        }
    }

}

extension OAuth2Service: ServiceProtocol {

    func request(filter: OAuth2Filter) -> SignalProducer<OAuthSwiftCredential, ServiceError> {
        let credential = oauth2Config.client.credential
        guard credential.oauthToken.isEmpty || credential.isTokenExpired() else {
            return SignalProducer(value: credential)
        }
        return SignalProducer { [weak self] observer, lifetime in
            guard let strongSelf = self else {
                observer.sendInterrupted()
                return
            }
            strongSelf.oauth2Config.renewAccessToken(withRefreshToken: credential.oauthRefreshToken, success: { (credential, response, parameters) in
                observer.send(value: credential)
                observer.sendCompleted()
            }, failure: { [weak self] error in
                guard let strongSelf = self else {
                    observer.sendInterrupted()
                    return
                }

                let handler = WebBrowser()
                let nc = UINavigationController(rootViewController: handler)
                handler.clearCache()
                handler.addTrigger(path: Consts.callbackUrl) { [weak handler] url in
                    OAuthSwift.handle(url: url)
                    handler?.dismiss(animated: true, completion: nil)
                }
                handler.addDoneAction { [weak handler] in
                    handler?.dismiss(animated: true, completion: nil)
                    observer.send(error: .cancelled)
                }
                strongSelf.oauth2Config.authorizeURLHandler = handler
                let scope = filter.scopes.joined(separator: ",")
                let state = OAuth2Service.generateState(withLength: 20)
                strongSelf.oauth2Config.authorize(withCallbackURL: Consts.callbackUrl, scope: scope, state: state, success: { (credential, response, parameters) in
                    observer.send(value: credential)
                    observer.sendCompleted()
                }, failure: { error in
                    observer.send(error: .authorizationFailed(error))
                })
                DispatchQueue.main.async {
                    self?.presenter(nc)
                }
            })
        }
    }

}

private extension OAuth2Service {

    static func generateState(withLength len: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let length = UInt32(letters.count)

        var randomString = ""
        for _ in 0..<len {
            let rand = arc4random_uniform(length)
            let idx = letters.index(letters.startIndex, offsetBy: Int(rand))
            let letter = letters[idx]
            randomString += String(letter)
        }
        return randomString
    }

}

extension WebBrowser: OAuthSwiftURLHandlerType {

    func handle(_ url: URL) {
        self.url = url
    }

}
