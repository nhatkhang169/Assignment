//
//  WeatherRepositoryTests.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import XCTest
@testable import Assignment

class WeatherRepositoryTests: XCTestCase {
    
    var sut: WeatherRepositoryImpl!
    var userDefaults: UserDefaultsMock!
    
    override func setUp() {
        userDefaults = UserDefaultsMock()
    }
    
    func testGetWeatherNotCachedWeatherShouldReturnNil() {
        // Given:
        sut = WeatherRepositoryImpl(expireTime: 1001,
                                    userDefaults: userDefaults)
    
        // When:
        let forecast = sut.getWeather(of: "Saigon", for: 14)
        
        // Then:
        XCTAssertNil(forecast)
        XCTAssertEqual(userDefaults.didGetDictionaryWithKey, "14_Saigon")
    }
    
    func testGetWeatherNoExpiredTimeShouldReturnNil() {
        // Given:
        userDefaults.mockDictionary = ["dummykey": "value"]
        sut = WeatherRepositoryImpl(expireTime: 1001,
                                    userDefaults: userDefaults)
        
        // When:
        let forecast = sut.getWeather(of: "Saigon", for: 14)
        
        // Then:
        XCTAssertNil(forecast)
        XCTAssertEqual(userDefaults.didGetDictionaryWithKey, "14_Saigon")
    }
    
    func testGetWeatherExpiredCachedWeatherShouldReturnNil() {
        // Given:
        let storedTime = Date().addingTimeInterval(-2000).timeIntervalSince1970
        userDefaults.mockDictionary = ["lastStoredTime": storedTime]
        sut = WeatherRepositoryImpl(expireTime: 1001,
                                    userDefaults: userDefaults)
        
        // When:
        let forecast = sut.getWeather(of: "Saigon", for: 14)
        
        // Then:
        XCTAssertNil(forecast)
        XCTAssertEqual(userDefaults.didGetDictionaryWithKey, "14_Saigon")
    }
    
    func testGetWeatherInvalidCachedWeatherShouldReturnNil() {
        // Given:
        let storedTime = Date().addingTimeInterval(-60).timeIntervalSince1970
        userDefaults.mockDictionary = [
            "lastStoredTime": storedTime,
            "data": "not Data type"
        ]
        sut = WeatherRepositoryImpl(expireTime: 1001,
                                    userDefaults: userDefaults)
        
        // When:
        let forecast = sut.getWeather(of: "Saigon", for: 14)
        
        // Then:
        XCTAssertNil(forecast)
        XCTAssertEqual(userDefaults.didGetDictionaryWithKey, "14_Saigon")
    }
    
    func testGetWeatherSuccess() {
        // Given:
        let storedTime = Date().addingTimeInterval(-60).timeIntervalSince1970
        let mockDayWeather = DayWeather(entity: DayWeatherEntity(dt: 10001,
                                                             temp: DayTempEntity(min: 28, max: 32),
                                                             pressure: 100, humidity: 35,
                                                             weather: [WeatherEntity(icon: "cloudy icon", description: "cloudy all day")]))
        let encoder = JSONEncoder()
        userDefaults.mockDictionary = [
            "lastStoredTime": storedTime,
            "data": try! encoder.encode([mockDayWeather])
        ]
        sut = WeatherRepositoryImpl(expireTime: 1001,
                                    userDefaults: userDefaults)
        
        // When:
        let forecast = sut.getWeather(of: "Saigon", for: 14)
        
        // Then:
        XCTAssertNotNil(forecast)
        let dayWeather = forecast?.first
        XCTAssertEqual(dayWeather?.icon, "cloudy icon")
        XCTAssertEqual(dayWeather?.description, "cloudy all day")
        XCTAssertEqual(dayWeather?.dt, 10001)
        XCTAssertEqual(dayWeather?.pressure, 100)
        XCTAssertEqual(dayWeather?.humidity, 35)
        XCTAssertEqual(dayWeather?.averageTemp, 30)
        XCTAssertEqual(userDefaults.didGetDictionaryWithKey, "14_Saigon")
    }
    
    func testSaveWeatherSuccessShouldUpdateStorage() {
        // Given:
        let mockDayWeather = DayWeather(entity: DayWeatherEntity(dt: 10001,
                                                             temp: DayTempEntity(min: 28, max: 32),
                                                             pressure: 100, humidity: 35,
                                                             weather: [WeatherEntity(icon: "cloudy icon", description: "cloudy all day")]))
        sut = WeatherRepositoryImpl(expireTime: 1001,
                                    userDefaults: userDefaults)
        
        // When:
        sut.saveWeather(of: "Saigon", for: 14, with: [mockDayWeather])
        
        // Then:
        XCTAssertEqual(userDefaults.didSetValue?.key, "14_Saigon")
        XCTAssertNotNil(userDefaults.didSetValue?.value)
        let cachedValue = userDefaults.didSetValue?.value as? [String: Any?]
        XCTAssertNotNil(cachedValue?["lastStoredTime"] as Any?)
        XCTAssertNotNil(cachedValue?["data"] as? Data)
    }
}
