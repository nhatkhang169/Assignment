//
//  ForecastViewController.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import UIKit
import RxCocoa

class ForecastViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }
    
    var query: String = "" {
        didSet {
            viewModel.fetch7DayForecast(for: query)
        }
    }
    
    var viewModel: ForecastViewModelProtocol = ForecastViewModel(interactor: Components.weatherInteractor())
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.register(ForecastCell.self, forCellReuseIdentifier: ForecastCell.identifier)
        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        view.tableHeaderView = UIView()
        view.allowsSelection = false
        return view
    }()
}

// MARK: - UITableViewDataSource

extension ForecastViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ForecastCell.identifier,
                                                       for: indexPath) as? ForecastCell,
              let forecast = viewModel.itemAt(index: indexPath.row) else {
                  return UITableViewCell()
        }
        
        let viewModel = ForecastCellViewModel(with: forecast)
        cell.viewModel = viewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
}

// MARK: - UITableViewDelegate

extension ForecastViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
}

// MARK: - Private

extension ForecastViewController {
    
    private func setupUI() {
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
    
    private func setupRx() {
        disposeBag.addDisposables([
            viewModel.onDidFetchForecast.subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            }),
        ])
    }
}
