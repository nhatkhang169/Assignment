//
//  ForecastJsonTransformer.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import SwiftyJSON

class ForecastJsonTransformer: JsonTransformer {
    
    let dayWeatherTransform: DayWeatherTransform
    init(dayWeatherTransform: DayWeatherTransform) {
        self.dayWeatherTransform = dayWeatherTransform
    }

    func transform(json: JSON) -> ForecastEntity {
        
        guard let list = json["list"].array else {
            return ForecastEntity(list: [])
        }
        
        return ForecastEntity(list: list.map { dayWeatherTransform.transform(json: $0) })
    }
}
