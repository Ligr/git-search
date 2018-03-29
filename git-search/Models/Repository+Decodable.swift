//
//  Repository+Decodable.swift
//  git-search
//
//  Created by Alex on 3/29/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

extension Repository: Decodable {

    private enum CodingKeys: String, CodingKey {
        case name
        case languages
        case stargazers
    }

    private enum LanguagesContainerKeys: String, CodingKey {
        case nodes
    }

    private enum StargazersContainerKeys: String, CodingKey {
        case totalCount
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)

        let languagesContainer = try values.nestedContainer(keyedBy: LanguagesContainerKeys.self, forKey: .languages)
        languages = try languagesContainer.decode([RepositoryLanguage].self, forKey: .nodes)

        let stargazersContainer = try values.nestedContainer(keyedBy: StargazersContainerKeys.self, forKey: .stargazers)
        starsCount = try stargazersContainer.decode(Int.self, forKey: .totalCount)
    }

}
