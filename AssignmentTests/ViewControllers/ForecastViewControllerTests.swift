//
//  ForecastViewControllerTests.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import XCTest
import RxSwift

@testable import Assignment

class ForecastViewControllerTests: XCTestCase {
    var sut: ForecastViewController!
    var viewModel: ForecastViewModelMock!
    let bag = DisposeBag()
    
    override func setUp() {
        viewModel = ForecastViewModelMock()
        sut = ForecastViewController()
    }
    
    func testGetNumberOfRowsInSectionShouldReturnByViewModel() {
        // Given:
        viewModel.numberOfItemsMock = 10
        sut.viewModel = viewModel
        
        // When:
        let noOfItems = sut.tableView(UITableView(), numberOfRowsInSection: 0)
        
        // Then
        XCTAssertEqual(noOfItems, viewModel.numberOfItemsMock)
    }
    
    func testCellForRowAtShouldReturnForecastCell() {
        // Given:
        viewModel.numberOfItemsMock = 10
        viewModel.itemAtMock = DayWeather(dt: 11, avgTemp: 22, pressure: 33, humidity: 44, icon: "icon", desc: "desc")
        sut.viewModel = viewModel
        sut.loadViewIfNeeded()
        viewModel.onDidFetchForecastSubject.onNext(())
        
        // When:
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(item: 0, section: 0))
        
        // Then
        XCTAssertEqual(viewModel.didGetItemAt, true)
        let forecastCell = cell as? ForecastCell
        XCTAssertNotNil(forecastCell)
        XCTAssertEqual(forecastCell?.viewModel?.tempText, "Average Temperature: 22°C")
        XCTAssertEqual(forecastCell?.viewModel?.pressureText, "Pressure: 33")
    }
    
    func testSetQueryShouldTriggerFetching() {
        // Given:
        sut.viewModel = viewModel
        let expectation = expectation(description: "Set Query to Fetch")
        viewModel.onDidFetchForecast
            .do { _ in
                expectation.fulfill()
            }
            .subscribe()
            .disposed(by: bag)

        
        // When:
        sut.query = "Melbourne"
        
        // Then
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.viewModel.didFetch7DayForecast, "Melbourne")
        }
    }
}
