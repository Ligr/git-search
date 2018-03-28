//
//  AppRouter.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit

protocol AppRouterType {
    func start(with session: SessionType) -> ViewType
}

final class AppRouter: AppRouterType {

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start(with session: SessionType) -> ViewType {
        let viewModel = RepositoriesViewModel(session: session)
        let view = RepositoriesView(viewModel: viewModel)
        window.rootViewController = view
        window.makeKeyAndVisible()
        return view
    }

}
