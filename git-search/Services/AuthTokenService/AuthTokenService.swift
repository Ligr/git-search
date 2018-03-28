//
//  AuthTokenService.swift
//  git-search
//
//  Created by Alex on 3/29/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol AuthTokenServiceProtocol {

    func authToken() -> SignalProducer<String, ServiceError>

}
