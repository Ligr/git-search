//
//  RepositoriesView.swift
//  git-search
//
//  Created by Alex on 3/28/18.
//  Copyright © 2018 Alex. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

final class RepositoriesView: BaseView<RepositoriesViewModelType>, UITableViewDataSource, UITableViewDelegate {

    private struct Consts {
        static let cellIdentifier = "cell"
        static let headerIdentifier = "header"
        static let headerHeight: CGFloat = 46
    }

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private var bindDisposable: ScopedDisposable<AnyDisposable>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func bindViewModel() {
        super.bindViewModel()
        let compositeDisposable = CompositeDisposable()
        bindDisposable = ScopedDisposable(compositeDisposable)

        compositeDisposable += searchTextField.reactive.continuousTextValues
        .skipRepeats(==)
        .debounce(1, on: QueueScheduler.main)
        .flatMap(.latest) { [unowned self] (query) -> SignalProducer<Void, NoError> in
            guard let query = query else {
                return .empty
            }
            return self.viewModel.searchRepository(by: query).observe(on: UIScheduler()).on(starting: { [unowned self] in
                self.activityIndicator.startAnimating()
            }, terminated: { [unowned self] in
                self.activityIndicator.stopAnimating()
            }).flatMapError { _ -> SignalProducer<Void, NoError> in
                return .empty
            }
        }.observeValues {

        }

        compositeDisposable += viewModel.groupedRepositories.signal.observe(on: UIScheduler()).observeValues { [weak self] _ in
            self?.tableView.setContentOffset(CGPoint(x: 1, y: 1), animated: false)
            self?.tableView.reloadData()
        }
    }

    @objc func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.groupedRepositories.value.count
    }

    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.groupedRepositories.value[section].repositories.count
    }

    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Consts.cellIdentifier, for: indexPath) as? RepositoryCellView else {
            assertionFailure("cell is not registered")
            return UITableViewCell()
        }
        let cellModel = viewModel.groupedRepositories.value[indexPath.section].repositories[indexPath.item]
        cell.viewModel = cellModel
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Consts.headerIdentifier) as? RepositoryHeaderView else {
            return nil
        }
        let group = viewModel.groupedRepositories.value[section]
        header.setName(group.language.name)
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Consts.headerHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.repositoryDetailsAction.apply(indexPath).start()
    }

}

private extension RepositoriesView {

    func setupView() {
        tableView.register(UINib(nibName: "RepositoryHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: Consts.headerIdentifier)
        tableView.register(UINib(nibName: "RepositoryCellView", bundle: nil), forCellReuseIdentifier: Consts.cellIdentifier)
        tableView.tableFooterView = UIView()
        edgesForExtendedLayout = []
        title = "Search Github"
    }

}
