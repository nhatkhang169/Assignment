//
//  ForecastViewModelMock.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import RxSwift

@testable import Assignment

class ForecastViewModelMock: ForecastViewModelProtocol {
    var onErrorSubject = PublishSubject<ApiError>()
    var onError: Observable<ApiError> {
        return onErrorSubject.asObservable()
    }
    
    var onDidFetchForecastSubject = PublishSubject<Void>()
    var onDidFetchForecast: Observable<Void> {
        return onDidFetchForecastSubject.asObservable()
    }
    
    var numberOfItemsMock: Int = 0
    var numberOfItems: Int {
        return numberOfItemsMock
    }
    
    var itemAtMock: DayWeather?
    private(set) var didGetItemAt: Bool = false
    func itemAt(index: Int) -> DayWeather? {
        didGetItemAt = true
        return itemAtMock
    }
    
    private(set) var didFetch7DayForecast: String?
    func fetch7DayForecast(for city: String) {
        didFetch7DayForecast = city
        onDidFetchForecastSubject.onNext(())
    }
}
