//
//  RouterType.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

protocol RouterType: class {
    var view: ViewType? { get }
    var session: SessionType { get }
}

class BaseRouter: RouterType {

    let session: SessionType
    private(set) weak var view: ViewType?

    init(session: SessionType, view: ViewType) {
        self.session = session
        self.view = view
    }

}
