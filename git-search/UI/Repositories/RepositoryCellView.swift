//
//  RepositoryCellView.swift
//  git-search
//
//  Created by Alex on 3/30/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit

final class RepositoryCellView: UITableViewCell {

    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var startCountLabel: UILabel!

    var viewModel: RepositoryType? {
        didSet {
            bindViewModel()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

}

private extension RepositoryCellView {

    func setupView() {
        nameLabel.text = nil
        startCountLabel.text = nil
    }

    func bindViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        nameLabel.text = viewModel.name
        startCountLabel.text = "\(viewModel.starsCount)"
    }

}
