//
//  ForecastViewModelTests.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import XCTest
import RxSwift

@testable import Assignment

class ForecastViewModelTests: XCTestCase {
    var sut: ForecastViewModel!
    var interactor: WeatherInteractorMock!
    let bag = DisposeBag()
    
    override func setUp() {
        interactor = WeatherInteractorMock()
    }
    
    func testGetNumberOfItemsShouldReturn0WhenNoApiCalled() {
        // Given:
        sut = ForecastViewModel(interactor: interactor)
        
        // When:
        let noOfItems = sut.numberOfItems
        
        // Then
        XCTAssertEqual(noOfItems, 0)
    }
    
    func testGetNumberOfItemsShouldReturnItemsWhenApiCalled() {
        // Given:
        interactor.result = [DayWeather(dt: 11, avgTemp: 22, pressure: 33, humidity: 44, icon: "icon", desc: "desc")]
        sut = ForecastViewModel(interactor: interactor)
        let expectation = expectation(description: "Get weather")
        sut.onDidFetchForecast
            .subscribe { _ in
                expectation.fulfill()
            }.disposed(by: bag)
        sut.fetch7DayForecast(for: "Saigon")
        
        // When:
        let noOfItems = sut.numberOfItems
        
        // Then
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(noOfItems, 1)
            XCTAssertEqual(self?.interactor.didGetWeather?.days, 7)
            XCTAssertEqual(self?.interactor.didGetWeather?.city, "Saigon")
        }
    }
    
    func testGetItemAtShouldReturnNilWhenNoApiCalled() {
        // Given:
        sut = ForecastViewModel(interactor: interactor)
        
        // When:
        let item = sut.itemAt(index: 0)
        
        // Then
        XCTAssertNil(item)
    }
    
    func testGetItemAtShouldReturnItemsWhenApiCalled() {
        // Given:
        interactor.result = [DayWeather(dt: 11, avgTemp: 22, pressure: 33, humidity: 44, icon: "icon", desc: "desc")]
        sut = ForecastViewModel(interactor: interactor)
        let expectation = expectation(description: "Get weather")
        sut.onDidFetchForecast
            .subscribe { _ in
                expectation.fulfill()
            }.disposed(by: bag)
        sut.fetch7DayForecast(for: "Saigon")
        
        // When:
        let item = sut.itemAt(index: 0)
        
        // Then
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(item?.dt, 11)
            XCTAssertEqual(item?.averageTemp, 22)
            XCTAssertEqual(item?.pressure, 33)
            XCTAssertEqual(item?.humidity, 44)
            XCTAssertEqual(item?.icon, "icon")
            XCTAssertEqual(item?.description, "desc")
            XCTAssertEqual(self?.interactor.didGetWeather?.days, 7)
            XCTAssertEqual(self?.interactor.didGetWeather?.city, "Saigon")
        }
    }
    
    func testFetch7DayForecastShouldInvokeApi() {
        // Given:
        interactor.result = [DayWeather(dt: 11, avgTemp: 22, pressure: 33, humidity: 44, icon: "icon", desc: "desc")]
        sut = ForecastViewModel(interactor: interactor)
        let expectation = expectation(description: "Get weather")
        sut.onDidFetchForecast
            .subscribe { _ in
                expectation.fulfill()
            }.disposed(by: bag)
        
        // When:
        sut.fetch7DayForecast(for: "Ho Chi Minh City")
        
        // Then
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.interactor.didGetWeather?.days, 7)
            XCTAssertEqual(self?.interactor.didGetWeather?.city, "Ho Chi Minh City")
        }
    }
    
    func testOnErrorShouldEmitWhenFetchingError() {
        // Given:
        interactor.error = ApiError.dataNotAvailable(description: "System failure")
        sut = ForecastViewModel(interactor: interactor)
        let expectation = expectation(description: "Get weather")
        sut.onError
            .do(onNext: { error in
                if case ApiError.dataNotAvailable(let description) = error {
                    XCTAssertEqual(description, "System failure")
                }
                else {
                    XCTFail("Invalid error")
                }
                
                expectation.fulfill()
            })
            .subscribe()
            .disposed(by: bag)
        
        // When:
        sut.fetch7DayForecast(for: "Ho Chi Minh City")
        
        // Then
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.interactor.didGetWeather?.days, 7)
            XCTAssertEqual(self?.interactor.didGetWeather?.city, "Ho Chi Minh City")
        }
    }
}
