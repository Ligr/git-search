//
//  ViewController.swift
//  git-search
//
//  Created by Alex on 3/26/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import ReactiveSwift

class ViewController: UIViewController {

    var auth: OAuth2Service!
    var container = Container()

    override func viewDidLoad() {
        super.viewDidLoad()

        let auth: OAuth2Service = container.resolve()
        self.auth = auth

//        auth = OAuth2Service(presenter: SignalProducer(value: self), oauth2Config: .github)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.auth.request(filter: .init(scopes: Constants.githubScopes)).startWithResult { result in
                switch result {
                case .success(let credential):
                    print(credential)
                case .failure(let error):
                    print(error)
                }
            }
        }


        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

