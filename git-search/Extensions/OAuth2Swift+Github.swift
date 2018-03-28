//
//  OAuth2Swift+Git.swift
//  git-search
//
//  Created by Alex on 3/27/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import OAuthSwift

private struct Consts {

    static let githubClientId = "d4a4be3f597e1693518d"
    static let githubClientSecret = "2083d6fcc722e708ff0b01b8b5a862848e839df1"
    static let githubAuthorizeUrl = "https://github.com/login/oauth/authorize"
    static let githubAccessTokenUrl = "https://github.com/login/oauth/access_token"
    static let githubResponseType = "code"

}

extension OAuth2Swift {

    static var github: OAuth2Swift {
        return OAuth2Swift(consumerKey: Consts.githubClientId,
                           consumerSecret: Consts.githubClientSecret,
                           authorizeUrl: Consts.githubAuthorizeUrl,
                           accessTokenUrl: Consts.githubAccessTokenUrl,
                           responseType: Consts.githubResponseType)
    }

}
