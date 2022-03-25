//
//  DayTempTransform.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import SwiftyJSON

class DayTempTransform: JsonTransformer {
    
    init() {
    }

    private static let fields = (
        min: "min",
        max: "max"
    )
    func transform(json: JSON) -> DayTempEntity {
        guard json != JSON.null else { return DayTempEntity(min: 0, max: 0) }
        let fields = DayTempTransform.fields
        return DayTempEntity(min: json[fields.min].doubleValue, max: json[fields.max].doubleValue)
    }
}
