//
//  UserDefaultsMock.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import SwiftyJSON
import RxSwift

@testable import Assignment

class UserDefaultsMock: UserDefaultsProtocol {
    
    var mockDictionary: [String: Any]?
    var didGetDictionaryWithKey: String?
    var didSetValue: (key: String, value: Any?)?
    
    func dictionary(forKey defaultName: String) -> [String : Any]? {
        didGetDictionaryWithKey = defaultName
        return mockDictionary
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        didSetValue = (defaultName, value)
    }
}
