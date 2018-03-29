//
//  RepositoryHeaderView.swift
//  git-search
//
//  Created by Alex on 3/30/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit

final class RepositoryHeaderView: UITableViewHeaderFooterView {

    @IBOutlet private var nameLabel: UILabel!

    func setName(_ name: String?) {
        nameLabel.text = name
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

}

private extension RepositoryHeaderView {

    func setupView() {
        nameLabel.text = nil
    }

}
