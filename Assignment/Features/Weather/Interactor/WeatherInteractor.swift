//
//  WeatherInteractor.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import RxSwift

protocol WeatherInteractor {
    func getWeather(of city: String, for days: Int) -> Observable<[DayWeather]>
}

class WeatherInteractorImpl: WeatherInteractor {
    private let forecastApi: ForecastApi
    
    init(forecastApi: ForecastApi) {
        self.forecastApi = forecastApi
    }
    
    func getWeather(of city: String, for days: Int) -> Observable<[DayWeather]> {
        return forecastApi.getWeather(of: city, for: days)
            .catchError { error -> Observable<ForecastEntity> in
                // TEMPORARY HIDE FAILURES
                return Observable.empty()
            }
            .map({ forecast in
                return forecast.list.map({ DayWeather(entity: $0) })
            })
        
    }
}
