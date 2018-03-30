//
//  RepositoryDetailsView.swift
//  git-search
//
//  Created by Alex on 3/30/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit

class RepositoryDetailsView: BaseView<RepositoryDetailsViewModel> {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var startCountLabel: UILabel!

    override func bindViewModel() {
        super.bindViewModel()
        nameLabel.text = viewModel.repositoryName
        startCountLabel.text = "\(viewModel.startCount)"
    }

}
