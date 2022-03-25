//
//  DayWeatherEntity.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

struct DayWeatherEntity {
    let dt: Double
    let temp: DayTempEntity
    let pressure: Int
    let humidity: Int
    let weather: [WeatherEntity]
}
