//
//  DayWeatherStub.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

@testable import Assignment

extension DayWeather {
    
    init(dt: Double = 0, avgTemp: Int = 0, pressure: Int = 0, humidity: Int = 0, icon: String = "", desc: String = "") {
        self.init(entity: DayWeatherEntity(dt: dt,
                                           temp: DayTempEntity(min: 0, max: Double(avgTemp * 2)),
                                           pressure: pressure,
                                           humidity: humidity,
                                           weather: [WeatherEntity(icon: icon,
                                                                   description: desc)]))
    }
}


extension DayWeatherEntity {
    init(dt: Double = 0, avgTemp: Int = 0, pressure: Int = 0, humidity: Int = 0, icon: String = "", desc: String = "") {
        self.init(dt: dt,
                  temp: DayTempEntity(min: 0, max: Double(avgTemp * 2)),
                  pressure: pressure, humidity: humidity,
                  weather: [WeatherEntity(icon: icon, description: desc)])
    }
}
