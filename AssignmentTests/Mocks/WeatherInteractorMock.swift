//
//  WeatherInteractorMock.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import RxSwift

@testable import Assignment

class WeatherInteractorMock: WeatherInteractor {
    
    private(set) var didGetWeather: (city: String, days: Int)?
    var result: [DayWeather]?
    
    var error: ApiError?
    private(set) var onErrorSubject = PublishSubject<ApiError>()
    
    func getWeather(of city: String, for days: Int) -> Observable<[DayWeather]> {
        didGetWeather = (city, days)
        
        if let forecast = result {
            return Observable.just(forecast)
        }
        
        if let err = error {
            onErrorSubject.onNext(err)
        }
        
        return Observable.empty()
    }
    
    var onError: Observable<ApiError> {
        onErrorSubject.asObservable()
    }
}
