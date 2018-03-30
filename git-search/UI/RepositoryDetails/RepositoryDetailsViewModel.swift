//
//  RepositoryDetailsViewModel.swift
//  git-search
//
//  Created by Alex on 3/30/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

protocol RepositoryDetailsViewModelType: ViewModelType {

    var repositoryName: String { get }
    var startCount: Int { get }

}

final class RepositoryDetailsViewModel: BaseViewModel<RepositoryDetailsRouter>, RepositoryDetailsViewModelType {

    var repositoryName: String {
        return repository.name
    }
    var startCount: Int {
        return repository.starsCount
    }

    private let repository: RepositoryType

    init(session: SessionType, repository: RepositoryType) {
        self.repository = repository
        super.init(session: session)
    }

}
