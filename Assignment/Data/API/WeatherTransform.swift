//
//  WeatherTransform.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import SwiftyJSON

class WeatherTransform: JsonTransformer {
    
    init() {
    }

    private static let fields = (
        icon: "icon",
        description: "description"
    )
    func transform(json: JSON) -> [WeatherEntity] {
        guard json != JSON.null else { return [WeatherEntity(icon: "", description: "")] }
        let fields = WeatherTransform.fields
        return json.arrayValue.map { WeatherEntity(icon: $0[fields.icon].stringValue,
                                                   description: $0[fields.description].stringValue) }
    }
}
