//
//  String+Extensions.swift
//  Assignment
//
//  Created by azun on 24/03/2022.
//

extension String {
    
    func formatWeatherIcon() -> String {
        let scale = Int(DeviceMetric.deviceScale)
        if scale == 1 {
            return self
        }
        return "\(self)@2x"
    }
}
