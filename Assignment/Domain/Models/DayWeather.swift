//
//  DayWeather.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

struct DayWeather {
    let dt: Double
    let averageTemp: Int
    let pressure: Int
    let humidity: Int
    let description: String
    let icon: String
    
    init(entity: DayWeatherEntity) {
        dt = entity.dt
        averageTemp = Int((entity.temp.min + entity.temp.max) / 2)
        humidity = entity.humidity
        pressure = entity.pressure
        description = entity.weather.first?.description ?? ""
        icon = entity.weather.first?.icon ?? ""
    }
}
