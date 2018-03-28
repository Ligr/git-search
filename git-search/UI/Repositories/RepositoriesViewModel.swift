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

protocol RepositoriesViewModelType: ViewModelType {
    var repositories: Property<[Repository]> { get }
}

final class RepositoriesViewModel: BaseViewModel<RepositoriesRouter>, RepositoriesViewModelType {

    let repositories: Property<[Repository]>

    private let service: GithubServiceProtocol

    override init(session: SessionType) {
        service = session.resolve()
        repositories = Property(initial: [], then: SignalProducer.empty)
        super.init(session: session)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.service.searchRepository(by: "Ligr").start()
        }
    }

}
