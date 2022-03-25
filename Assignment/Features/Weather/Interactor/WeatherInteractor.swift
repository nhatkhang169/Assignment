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
    private let weatherRepository: WeatherRepository
    private let errorSubject = PublishSubject<ApiError>()
    
    init(forecastApi: ForecastApi, weatherRepository: WeatherRepository) {
        self.forecastApi = forecastApi
        self.weatherRepository = weatherRepository
    }
    
    func getWeather(of city: String, for days: Int) -> Observable<[DayWeather]> {
        if let dayWeathers = weatherRepository.getWeather(of: city, for: days) {
            return Observable.just(dayWeathers)
        }
        
        return forecastApi.getWeather(of: city, for: days)
            .catchError { [weak self] error -> Observable<ForecastEntity> in
                if let err = error as? ApiError {
                    self?.errorSubject.onNext(err)
                }
                else {
                    let unknownError = ApiError.other(httpErrorCode: 0, statusCode: 0,
                                                      description: "Something went wrong")
                    self?.errorSubject.onNext(unknownError)
                }
                
                return Observable.empty()
            }
            .map({ forecast in
                return forecast.list.map({ DayWeather(entity: $0) })
            })
            .do { [weak self] dayWeathers in
                self?.weatherRepository.saveWeather(of: city, for: days, with: dayWeathers)
            }
        
    }
    
    var onError: Observable<ApiError> {
        return errorSubject.asObservable()
    }
}
