//
//  DayWeatherTransform.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import SwiftyJSON

class DayWeatherTransform: JsonTransformer {
    let dayTempTransform: DayTempTransform
    let weatherTransform: WeatherTransform
    
    init(dayTempTransform: DayTempTransform, weatherTransform: WeatherTransform) {
        self.dayTempTransform = dayTempTransform
        self.weatherTransform = weatherTransform
    }

    private static let fields = (
        dt: "dt",
        temp: "temp",
        pressure: "pressure",
        humidity: "humidity",
        weather: "weather"
    )
    
    func transform(json: JSON) -> DayWeatherEntity {
        let fields = DayWeatherTransform.fields
        return DayWeatherEntity(dt: json[fields.dt].doubleValue,
                                temp: dayTempTransform.transform(json: json[fields.temp]),
                                pressure: json[fields.pressure].intValue,
                                humidity: json[fields.humidity].intValue,
                                weather: weatherTransform.transform(json: json[fields.weather]))
    }
}
