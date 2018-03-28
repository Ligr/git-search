//
//  DataResult.swift
//  DataKit
//
//  Created by Alex on 1/11/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

enum DataUpdate {
    case insert(IndexPath)
    case remove(IndexPath)
    case update(IndexPath)
}

protocol DataResultProtocol {
    
    associatedtype Item
    
    var items: [Item] { get }
    var count: Int { get }
    var updates: Signal<[DataUpdate], NoError> { get }
    
}
