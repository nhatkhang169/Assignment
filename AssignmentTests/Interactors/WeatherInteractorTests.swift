//
//  WeatherInteractorTests.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import XCTest
import RxSwift

@testable import Assignment

class WeatherInteractorTests: XCTestCase {
    
    var sut: WeatherInteractorImpl!
    var api: ForecastApiMock!
    var repo: WeatherRepositoryMock!
    let bag = DisposeBag()
    
    override func setUp() {
        api = ForecastApiMock()
        repo = WeatherRepositoryMock()
    }
    
    func testGetWeatherReturnShouldCache() {
        // Given:
        repo.result = [DayWeather(dt: 1001)]
        sut = WeatherInteractorImpl(forecastApi: api, weatherRepository: repo)
        let expectation = expectation(description: "Get Weather")
        
        // When:
        sut.getWeather(of: "Saigon", for: 14)
            .do { forecast in
                XCTAssertEqual(forecast.first?.dt, 1001)
                expectation.fulfill()
            }.subscribe()
            .disposed(by: bag)
        
        // Then
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.repo.didGetWeather?.city, "Saigon")
            XCTAssertEqual(self?.repo.didGetWeather?.days, 14)
        }
    }
    
    func testGetWeatherNoCacheAndReturnErrorShouldBeTriggerOnError() {
        // Given:
        api.error = ApiError.dataNotAvailable(description: "System Failture")
        
        sut = WeatherInteractorImpl(forecastApi: api, weatherRepository: repo)
        let expectation = expectation(description: "Get Weather With Error")
        
        sut.onError
            .do(onNext: { error in
                XCTAssertEqual(error.description, "System Failture")
                expectation.fulfill()
            })
            .subscribe()
            .disposed(by: bag)
        
        // When:
        sut.getWeather(of: "Saigon", for: 14)
            .do { _ in
                // SHOULD NOT HAPPEN OR FAIL
                expectation.fulfill()
            }
            .subscribe()
            .disposed(by: bag)
        
        // Then
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.repo.didGetWeather?.city, "Saigon")
            XCTAssertEqual(self?.repo.didGetWeather?.days, 14)
        }
    }
    
    func testGetWeatherNoCacheAndReturnUnknownErrorShouldBeTriggerOnError() {
        // Given:
        api.error = NSError(domain: "domain", code: 100101, userInfo: nil)
        
        sut = WeatherInteractorImpl(forecastApi: api, weatherRepository: repo)
        let expectation = expectation(description: "Get Weather With Unknown Error")
        
        sut.onError
            .do(onNext: { error in
                XCTAssertEqual(error.description, "Something went wrong")
                expectation.fulfill()
            })
            .subscribe()
            .disposed(by: bag)
        
        // When:
        sut.getWeather(of: "Saigon", for: 14)
            .do { _ in
                // SHOULD NOT HAPPEN OR FAIL
                expectation.fulfill()
            }
            .subscribe()
            .disposed(by: bag)
        
        // Then
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.repo.didGetWeather?.city, "Saigon")
            XCTAssertEqual(self?.repo.didGetWeather?.days, 14)
        }
    }
    
    func testGetWeatherNoCacheAndReturnValidDataShouldTriggerSavingCache() {
        // Given:
        api.result = ForecastEntity(list: [DayWeatherEntity(dt: 1001)])
        
        sut = WeatherInteractorImpl(forecastApi: api, weatherRepository: repo)
        let expectation = expectation(description: "Get Remote Weather")
        
        // When:
        sut.getWeather(of: "Saigon", for: 14)
            .do { forecast in
                XCTAssertEqual(forecast.first?.dt, 1001)
                expectation.fulfill()
            }
            .subscribe()
            .disposed(by: bag)
        
        // Then
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.api.didGetWeather?.city, "Saigon")
            XCTAssertEqual(self?.api.didGetWeather?.forDays, 14)
            
            XCTAssertEqual(self?.repo.didGetWeather?.city, "Saigon")
            XCTAssertEqual(self?.repo.didGetWeather?.days, 14)
            
            XCTAssertEqual(self?.repo.didSaveWeather?.days, 14)
            XCTAssertEqual(self?.repo.didSaveWeather?.city, "Saigon")
            XCTAssertEqual(self?.repo.didSaveWeather?.forecast.first?.dt, 1001)
        }
    }
}
