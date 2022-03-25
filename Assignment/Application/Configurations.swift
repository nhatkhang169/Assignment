//
//  Configurations.swift
//  F8
//
//  Created by Tuyen Nguyen Thanh on 10/12/16.
//  Copyright © 2016 Tuyen Nguyen Thanh. All rights reserved.
//

import Foundation
import UIKit

class Configurations {

    let apiBaseUrl: String
    let weatherIconUrl: String
    
    init(dictionary: NSDictionary) {
        apiBaseUrl = dictionary["apiBaseUrl"] as! String
        weatherIconUrl = dictionary["weatherIconUrl"] as! String
    }
}
