//
//  ForecastApiTests.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import XCTest
import RxSwift

@testable import Assignment

class ForecastApiTests: XCTestCase {
    var sut: ForecastApiImpl!
    var mockApiClient: ApiClientMock<ForecastEntity>!
    
    override func setUp() {
        super.setUp()
        
        mockApiClient = ApiClientMock<ForecastEntity>()
        sut = ForecastApiImpl(apiClient: mockApiClient,
                              transformer: Components.instance.forecastJsonTransformer.transform)
    }

    func testGetWeatherSuccessWithEmptyList() {
        // Given:
        let bag = DisposeBag()
        let expectation = expectation(description: "Success Call")
        mockApiClient.result = ForecastEntity(list: [])
        
        // When:
        sut.getWeather(of: "Saigon", for: 14)
            .do(onNext: { entity in
                XCTAssertTrue(entity.list.isEmpty)
                expectation.fulfill()
            })
            .subscribe()
            .disposed(by: bag)
        
        // Then:
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.mockApiClient.requestedMethod, .get)
            XCTAssertEqual(self?.mockApiClient.requestedUrl, "/data/2.5/forecast/daily")
            XCTAssertEqual(self?.mockApiClient.requestedParams?.count, 4)
            XCTAssertEqual(self?.mockApiClient.requestedParams?["q"] as? String, "Saigon")
            XCTAssertEqual(self?.mockApiClient.requestedParams?["cnt"] as? Int, 14)
        }
    }
    
    func testGetWeatherSuccessWithSomeItemsReturned() {
        // Given:
        let bag = DisposeBag()
        let expectation = expectation(description: "Success Call")
        mockApiClient.result = ForecastEntity(list: [
            DayWeatherEntity(dt: 19001590,
                             temp: DayTempEntity(min: 28, max: 32),
                             pressure: 100,
                             humidity: 30,
                             weather: [WeatherEntity(icon: "cloudy icon",
                                                     description: "cloudy all day")])
        ])
        
        // When:
        sut.getWeather(of: "Saigon", for: 14)
            .do(onNext: { entity in
                XCTAssertEqual(entity.list.count, 1)
                let dayWeather = entity.list.first
                XCTAssertEqual(dayWeather?.humidity, 30)
                XCTAssertEqual(dayWeather?.pressure, 100)
                XCTAssertEqual(dayWeather?.dt, 19001590)
                XCTAssertEqual(dayWeather?.temp.min, 28)
                XCTAssertEqual(dayWeather?.temp.max, 32)
                XCTAssertEqual(dayWeather?.weather.first?.icon, "cloudy icon")
                XCTAssertEqual(dayWeather?.weather.first?.description, "cloudy all day")
                expectation.fulfill()
            })
            .subscribe()
            .disposed(by: bag)
        
        // Then:
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.mockApiClient.requestedMethod, .get)
            XCTAssertEqual(self?.mockApiClient.requestedUrl, "/data/2.5/forecast/daily")
            XCTAssertEqual(self?.mockApiClient.requestedParams?.count, 4)
            XCTAssertEqual(self?.mockApiClient.requestedParams?["q"] as? String, "Saigon")
            XCTAssertEqual(self?.mockApiClient.requestedParams?["cnt"] as? Int, 14)
        }
    }
    
    func testGetWeatherFailureShouldSimplyThrowError() {
        // Given:
        let bag = DisposeBag()
        let expectation = expectation(description: "Failure Call")
        mockApiClient.error = ApiError.dataNotAvailable(description: "System failure")
        
        // When:
        sut.getWeather(of: "Saigon", for: 14)
            .catchError({ error in
                if case let ApiError.dataNotAvailable(description) = error {
                    XCTAssertEqual(description, "System failure")
                }
                else {
                    XCTFail("Error not matched")
                }
                expectation.fulfill()
                return Observable.empty()
            })
            .subscribe()
            .disposed(by: bag)
        
        // Then:
        waitForExpectations(timeout: 0.1) { [weak self] _ in
            XCTAssertEqual(self?.mockApiClient.requestedMethod, .get)
            XCTAssertEqual(self?.mockApiClient.requestedUrl, "/data/2.5/forecast/daily")
            XCTAssertEqual(self?.mockApiClient.requestedParams?.count, 4)
            XCTAssertEqual(self?.mockApiClient.requestedParams?["q"] as? String, "Saigon")
            XCTAssertEqual(self?.mockApiClient.requestedParams?["cnt"] as? Int, 14)
        }
    }

}
