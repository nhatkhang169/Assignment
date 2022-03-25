//
//  ForecastCellViewModel.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import Foundation

protocol ForecastCellViewModelProtocol {
    var dateText: String { get }
    var tempText: String { get }
    var pressureText: String { get }
    var humidityText: String { get }
    var descText: String { get }
    var iconUrl: URL? { get }
}

class ForecastCellViewModel: BaseViewModel {
    
    private let model: DayWeather
    
    init(with forecast: DayWeather) {
        model = forecast
    }
    
    private lazy var dateFormatter: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy"
        return formatter
    }()
}

// MARK - ForecastCellViewModelProtocol

extension ForecastCellViewModel: ForecastCellViewModelProtocol {
    var dateText: String {
        let date = Date(timeIntervalSince1970: model.dt)
        return "Date: \(dateFormatter.string(for: date) ?? "")"
    }
    
    var tempText: String {
        return "Average Temperature: \(model.averageTemp)°C"
    }
    
    var pressureText: String {
        return "Pressure: \(model.pressure)"
    }
    
    var humidityText: String {
        return "Humidity: \(model.humidity)%"
    }
    
    var descText: String {
        return "Description: \(model.description)"
    }
    
    var iconUrl: URL? {
        let remoteFilePathFormat = Components.instance.configurations.weatherIconUrl
        let remoteFilePath = String(format: remoteFilePathFormat, model.icon.formatWeatherIcon())
        return URL(string: remoteFilePath)
    }
}

// MARK - Private

extension ForecastCellViewModel {
    
}
