//
//  RxSwift+Extensions.swift
//  Assignment
//
//  Created by azun on 20/03/2022.
//

import RxSwift

extension DisposeBag {
    func addDisposables(_ array: [Disposable]) {
        for item in array {
            self.insert(item)
        }
    }
}
