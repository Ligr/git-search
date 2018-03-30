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
    var groupedRepositories: Property<[GroupedRepositoriesViewModelType]> { get }
    var repositoryDetailsAction: Action<IndexPath, Void, NoError> { get }

    func searchRepository(by owner: String) -> SignalProducer<Void, ServiceError>
}

final class RepositoriesViewModel: BaseViewModel<RepositoriesRouter>, RepositoriesViewModelType {

    private struct Consts {
        static let minQueryLength: Int = 3
    }

    let groupedRepositories: Property<[GroupedRepositoriesViewModelType]>
    private let _groupedRepositories: MutableProperty<[GroupedRepositoriesViewModelType]> = MutableProperty([])

    private let service: GithubServiceProtocol

    private(set) lazy var repositoryDetailsAction: Action<IndexPath, Void, NoError> = {
        return Action { [weak self] indexPath in
            return SignalProducer { [weak self] observer, lifetime in
                guard let strongSelf = self else {
                    observer.sendInterrupted()
                    return
                }
                let group = strongSelf.groupedRepositories.value[indexPath.section]
                let repository = group.repositories[indexPath.item]
                strongSelf.router?.goToRepository(repository)
                observer.sendCompleted()
            }
        }
    }()

    override init(session: SessionType) {
        service = session.resolve()
        groupedRepositories = Property(_groupedRepositories)
        super.init(session: session)
    }

    func searchRepository(by owner: String) -> SignalProducer<Void, ServiceError> {
        guard owner.count >= Consts.minQueryLength else {
            _groupedRepositories.value = []
            return .empty
        }
        return self.service.searchRepository(by: owner).map { [weak self] repos -> Void in
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
            let groupedRepositories = langsMap.flatMap { lang -> (RepositoryLanguageType, [RepositoryType])? in
                if let repos = reposMap[lang.key] {
                    return (lang.value, repos)
                }
                return nil
            }.sorted {
                $0.1.count > $1.1.count
            }.map {
                return GroupedRepositoriesViewModel(language: $0.0, repositories: $0.1)
            }
            self?._groupedRepositories.value = groupedRepositories
        }
    }

}
