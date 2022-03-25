//
//  UserDefaultsProtocol.swift
//  Assignment
//
//  Created by azun on 25/03/2022.
//

import Foundation

protocol UserDefaultsProtocol {
    
    func dictionary(forKey defaultName: String) -> [String : Any]?
    func set(_ value: Any?, forKey defaultName: String)
}

// MARK: - UserDefaultsProtocol

extension UserDefaults: UserDefaultsProtocol {
    
}
