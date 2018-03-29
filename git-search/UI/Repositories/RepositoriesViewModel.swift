//
//  RepositoriesViewModel.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol GroupedRepositoriesViewModelType {
    var language: RepositoryLanguageType { get }
    var repositories: [RepositoryType] { get }
}

final class GroupedRepositoriesViewModel: GroupedRepositoriesViewModelType {
    let language: RepositoryLanguageType
    let repositories: [RepositoryType]

    init(language: RepositoryLanguageType, repositories: [RepositoryType]) {
        self.language = language
        self.repositories = repositories
    }
}

protocol RepositoriesViewModelType: ViewModelType {
    func searchRepository(by owner: String) -> SignalProducer<[GroupedRepositoriesViewModelType], ServiceError>
}

final class RepositoriesViewModel: BaseViewModel<RepositoriesRouter>, RepositoriesViewModelType {

    private let service: GithubServiceProtocol

    override init(session: SessionType) {
        service = session.resolve()
        super.init(session: session)
    }

    func searchRepository(by owner: String) -> SignalProducer<[GroupedRepositoriesViewModelType], ServiceError> {
        return self.service.searchRepository(by: owner).map { repos -> [GroupedRepositoriesViewModelType] in
            var reposMap = [String: [RepositoryType]]()
            var langsMap = [String: RepositoryLanguageType]()
            for repo in repos {
                for lang in repo.languages {
                    var sameRepos: [RepositoryType]
                    if let existingRepos = reposMap[lang.name] {
                        sameRepos = existingRepos
                    } else {
                        sameRepos = []
                        langsMap[lang.name] = lang
                    }
                    sameRepos.append(repo)
                    reposMap[lang.name] = sameRepos
                }
            }
            return langsMap.flatMap { lang -> (RepositoryLanguageType, [RepositoryType])? in
                if let repos = reposMap[lang.key] {
                    return (lang.value, repos)
                }
                return nil
            }.sorted {
                $0.1.count > $1.1.count
            }.map {
                return GroupedRepositoriesViewModel(language: $0.0, repositories: $0.1)
            }
        }
    }

}
