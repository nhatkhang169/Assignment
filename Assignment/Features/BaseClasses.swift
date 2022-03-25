//
//  BaseClasses.swift
//  MBC
//
//  Created by Tuyen Nguyen Thanh on 10/3/16.
//  Copyright © 2016 MBC. All rights reserved.
//

import Foundation
import RxSwift

class BaseViewModel {
    let disposeBag = DisposeBag()
}

class BaseViewController: UIViewController {
    let disposeBag = DisposeBag()
}
