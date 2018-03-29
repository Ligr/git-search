//
//  RepositoryResponse.swift
//  git-search
//
//  Created by Alex on 3/29/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

protocol RepositoryResponseType {
    var pageInfo: PageInfoType { get }
    var repositories: [RepositoryType] { get }
}

struct RepositoryResponse: RepositoryResponseType {

    let pageInfo: PageInfoType
    let repositories: [RepositoryType]

}
