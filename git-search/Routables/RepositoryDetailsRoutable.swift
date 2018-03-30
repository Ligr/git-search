//
//  RepositoryDetailsRoutable.swift
//  git-search
//
//  Created by Alex on 3/30/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

protocol RepositoryDetailsRoutable {

    func goToRepository(_ repository: RepositoryType)

}

extension RepositoryDetailsRoutable where Self: RouterType {

    func goToRepository(_ repository: RepositoryType) {
        let viewModel = RepositoryDetailsViewModel(session: session, repository: repository)
        let view = RepositoryDetailsView(viewModel: viewModel)
        let router = RepositoryDetailsRouter(session: session, view: view)
        viewModel.router = router
        self.view?.navigationController?.pushViewController(view, animated: true)
    }

}
