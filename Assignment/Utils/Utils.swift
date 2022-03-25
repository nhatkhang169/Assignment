//
//  Utils.swift
//  Assignment
//
//  Created by azun on 21/03/2022.
//

import Foundation
import SwiftyJSON

struct Utils {
    static func loadJsonFromFile(name: String) -> JSON? {
        if let path = Bundle.main.path(forResource: name, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                return try JSON(data: data)
                
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename/path.")
        }
        
        return nil
    }
}
