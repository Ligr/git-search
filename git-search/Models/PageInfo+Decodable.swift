//
//  PageInfo+Decodable.swift
//  git-search
//
//  Created by Alex on 3/29/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

extension PageInfo: Decodable {

    private enum CodingKeys: String, CodingKey {
        case hasNextPage
        case endCursor
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        hasNextPage = try values.decode(Bool.self, forKey: .hasNextPage)
        endCursor = try values.decode(String.self, forKey: .endCursor)
    }

}
