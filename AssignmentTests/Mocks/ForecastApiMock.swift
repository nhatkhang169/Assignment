//
//  ForecastApiMock.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import RxSwift

@testable import Assignment

class ForecastApiMock: ForecastApi {
    private(set) var didGetWeather: (city: String, forDays: Int)?
    
    var result: ForecastEntity?
    var error: Error?
    
    func getWeather(of city: String, for days: Int) -> Observable<ForecastEntity> {
        didGetWeather = (city, days)
        
        if let entity = result {
            return Observable.just(entity)
        }
        
        if let err = error {
            return Observable.error(err)
        }
        
        return Observable.error(ApiError.other(httpErrorCode: 0, statusCode: 0, description: "Unknown error"))
    }
}
