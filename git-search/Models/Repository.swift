//
//  Repository.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

protocol RepositoryType {
    var name: String { get }
    var starsCount: Int { get }
    var languages: [RepositoryLanguageType] { get }
}

struct Repository: RepositoryType {
    let name: String
    let starsCount: Int
    let languages: [RepositoryLanguageType]
}
