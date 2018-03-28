//
//  ViewModel.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

protocol ViewModelType: class {
    
}

class BaseViewModel<Router: RouterType>: ViewModelType {

    let session: SessionType
    var router: Router?

    init(session: SessionType) {
        self.session = session
    }

}
