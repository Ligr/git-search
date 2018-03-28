//
//  ModalRoutable.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit

protocol ModalRoutable {

    func presentModally(_ controller: UIViewController)

}

extension ModalRoutable where Self: RouterType {

    func presentModally(_ controller: UIViewController) {
        view?.present(controller, animated: true, completion: nil)
    }

}
