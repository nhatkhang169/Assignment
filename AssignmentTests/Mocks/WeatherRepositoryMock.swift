//
//  WeatherRepositoryMock.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

@testable import Assignment

class WeatherRepositoryMock: WeatherRepository {
    private(set) var didGetWeather: (city: String, days: Int)?
    private(set) var didSaveWeather: (city: String, days: Int, forecast: [DayWeather])?
    
    var result: [DayWeather]?
    
    func getWeather(of city: String, for days: Int) -> [DayWeather]? {
        didGetWeather = (city, days)
        return result
    }
    
    func saveWeather(of city: String, for days: Int, with forecast: [DayWeather]) {
        didSaveWeather = (city, days, forecast)
    }
}
