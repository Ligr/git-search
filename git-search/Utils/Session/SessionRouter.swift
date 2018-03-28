//
//  SessionRouter.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit

protocol SessionRouterType: ModalRoutable {

}

final class SessionRouter: RouterType, SessionRouterType {

    private(set) weak var view: ViewType?
    init(view: ViewType) {
        self.view = view
    }

}
