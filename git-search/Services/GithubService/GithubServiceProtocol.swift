//
//  GithubServiceProtocol.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol GithubServiceProtocol {

    func searchRepository(by owner: String) -> SignalProducer<[RepositoryType], ServiceError>

}
