//
//  JsonTransformer.swift
//  Assignment
//
//  Created by azun on 20/03/2022.
//

import SwiftyJSON

protocol JsonTransformer {
    associatedtype Model
    func transform(json: JSON) -> Model
}
