//
//  PageInfo.swift
//  git-search
//
//  Created by Alex on 3/29/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation

protocol PageInfoType {
    var endCursor: String { get }
    var hasNextPage: Bool { get }
}

struct PageInfo: PageInfoType {

    let endCursor: String
    let hasNextPage: Bool

}
