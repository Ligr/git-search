//
//  Container.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

final class Container {

    private var cache: [String: Any] = [:]

    func register<T>(_ entity: T.Type, constructor: @escaping (Container) -> T) {
        let identifier = String(describing: entity)
        cache[identifier] = constructor
    }

    func resolve<T>() -> T {
        let identifier = String(describing: T.self)
        guard let constructor = cache[identifier] as? ((Container) -> T) else {
            fatalError("\(identifier) is not registered in container")
        }
        return constructor(self)
    }

}
