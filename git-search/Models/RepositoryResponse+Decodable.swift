//
//  RepositoryResponse+Decodable.swift
//  git-search
//
//  Created by Alex on 3/29/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

extension RepositoryResponse: Decodable {

    private enum CodingKeys: String, CodingKey {
        case pageInfo
        case nodes
    }

    private enum DataCodingKeys: String, CodingKey {
        case data
    }

    private enum RepositoryOwnerCodingKeys: String, CodingKey {
        case repositoryOwner
    }

    private enum RepositoriesCodingKeys: String, CodingKey {
        case repositories
    }

    init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: DataCodingKeys.self)
        let repositoryOwnerContainer = try dataContainer.nestedContainer(keyedBy: RepositoryOwnerCodingKeys.self, forKey: .data)
        let repositoriesContainer = try repositoryOwnerContainer.nestedContainer(keyedBy: RepositoriesCodingKeys.self, forKey: .repositoryOwner)
        let values = try repositoriesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .repositories)
        pageInfo = try values.decode(PageInfo.self, forKey: .pageInfo)
        repositories = try values.decode([Repository].self, forKey: .nodes)
    }

}
