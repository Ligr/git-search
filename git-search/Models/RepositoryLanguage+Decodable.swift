//
//  RepositoryLanguage+Decodable.swift
//  git-search
//
//  Created by Alex on 3/29/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

extension RepositoryLanguage: Decodable {

    private enum CodingKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
    }

}
