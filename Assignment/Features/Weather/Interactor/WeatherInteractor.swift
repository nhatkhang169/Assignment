//
//  WeatherInteractor.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import RxSwift

protocol WeatherInteractor {
    func getWeather(of city: String, for days: Int) -> Observable<[DayWeather]>
    var onError: Observable<ApiError> { get }
}

class WeatherInteractorImpl: WeatherInteractor {
    private let forecastApi: ForecastApi
    private let errorSubject = PublishSubject<ApiError>()
    
    init(forecastApi: ForecastApi) {
        self.forecastApi = forecastApi
    }
    
    func getWeather(of city: String, for days: Int) -> Observable<[DayWeather]> {
        return forecastApi.getWeather(of: city, for: days)
            .catchError { [weak self] error -> Observable<ForecastEntity> in
                if let err = error as? ApiError {
                    self?.errorSubject.onNext(err)
                }
                
                return Observable.empty()
            }
            .map({ forecast in
                return forecast.list.map({ DayWeather(entity: $0) })
            })
        
    }
    
    var onError: Observable<ApiError> {
        return errorSubject.asObservable()
    }
}
