//
//  ForecastApi.swift
//  Assignment
//
//  Created by azun on 23/03/2022.
//

import RxSwift
import SwiftyJSON

protocol ForecastApi {
    func getWeather(of city: String, for days: Int) -> Observable<ForecastEntity>
}

class ForecastApiImpl: BaseApiClient<ForecastEntity>, ForecastApi {
    
    let transformer: (JSON) -> ForecastEntity
    
    init(apiClient: ApiClient, transformer: @escaping (JSON) -> ForecastEntity) {
        self.transformer = transformer
        super.init(apiClient: apiClient, jsonTransformer: transformer)
    }
    private static let appId = "60c6fbeb4b93ac653c492ba806fc346d"
    private static let units = "metric"
    private static let url = "/data/2.5/forecast/daily"
    private static let fields = (
        q: "q",
        cnt: "cnt",
        appId: "appId",
        units: "units"
    )
    func getWeather(of city: String, for days: Int) -> Observable<ForecastEntity> {
        let fields = ForecastApiImpl.fields
        let params: [String: Any] = [
            fields.appId: ForecastApiImpl.appId,
            fields.cnt: days,
            fields.units:ForecastApiImpl.units,
            fields.q: city
        ]
        return apiClient.get(ForecastApiImpl.url,
                             parameters: params,
                             errorHandler: { _, error -> Error in
                                return error
        }, parse: transformer)
    }
}
