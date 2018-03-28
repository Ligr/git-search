//
//  RepositoryLanguage.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

protocol RepositoryLanguageType {
    var name: String { get }
}

struct RepositoryLanguage: RepositoryLanguageType {
    let name: String
}
