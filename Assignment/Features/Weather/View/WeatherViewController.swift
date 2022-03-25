//
//  WeatherViewController.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import UIKit

class WeatherViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: ForecastViewController())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - UISearchResultsUpdating

extension WeatherViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }
        
        let city = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard city.count > 2 else {
            searchController.hideResultView()
            return
        }
        searchController.showResultView()
        guard let resultController = searchController.searchResultsController as? ForecastViewController else {
            return
        }
        
        resultController.query = city
    }
    
}

// MARK: - Private

extension WeatherViewController {
    private func setupUI() {
        title = "Weather Forecast"
        
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
    }
}
