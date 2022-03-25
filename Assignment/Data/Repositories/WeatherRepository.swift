//
//  WeatherRepository.swift
//  Assignment
//
//  Created by azun on 24/03/2022.
//

import RxSwift
import Foundation

protocol WeatherRepository {
    func getWeather(of city: String, for days: Int) -> [DayWeather]?
    func saveWeather(of city: String, for days: Int, with forecast: [DayWeather]) -> Void
}

final class WeatherRepositoryImpl {
    private let lastStoredTimeKey = "lastStoredTime"
    private let dataKey =           "data"
    
    private var expireTime: Int = 0
    private var userDefaults: UserDefaultsProtocol
    init(expireTime: Int, userDefaults: UserDefaultsProtocol = UserDefaults.standard) {
        self.expireTime = expireTime
        self.userDefaults = userDefaults
    }
}

extension WeatherRepositoryImpl: WeatherRepository {
    func getWeather(of city: String, for days: Int) -> [DayWeather]? {
        let key = formatKey(city: city, days: days)
        guard let dictionary = userDefaults.dictionary(forKey: key) else {
            return nil
        }
        
        guard let lastStoredTime = dictionary[lastStoredTimeKey] as? Double else {
            return nil
        }
        let duration = Date().timeIntervalSince1970 - lastStoredTime
        if lastStoredTime == 0 || duration > Double(expireTime) {
            return nil
        }
        guard let encodedData = dictionary[dataKey] as? Data else {
            return nil
        }
        
        return try? JSONDecoder().decode([DayWeather].self, from: encodedData)
    }
    
    func saveWeather(of city: String, for days: Int, with forecast: [DayWeather]) {
        let key = formatKey(city: city, days: days)
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(forecast) {
            let dictionary = [dataKey: encodedData,
                              lastStoredTimeKey: Date().timeIntervalSince1970] as [String: Any]
            
            userDefaults.set(dictionary, forKey: key)
        }
    }
    
    private func formatKey(city: String, days: Int) -> String {
        return "\(days)_\(city)"
    }
}
