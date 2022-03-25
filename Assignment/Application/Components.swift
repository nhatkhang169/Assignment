//
//  Components.swift
//  MBC
//
//  Created by Khang Nguyen Nhat on 11/24/17.
//  Copyright © 2017 MBC. All rights reserved.
//

import Foundation

class Components {

    // MARK: Public

    static let instance = Components()

    static var networkingService: NetworkingService {
        return instance.internalNetworkingService
    }
    
    //----------------------------------------------------------------------------------------------
    // MARK: Common */

    lazy var configurations: Configurations = {
        let path = Bundle.main.path(forResource: "configuration", ofType: "plist")!
        let dictionary = NSDictionary(contentsOfFile: path)!
        return Configurations(dictionary: dictionary)
    }()

    private lazy var apiClient: ApiClient = {
        return ApiClientImpl(baseUrl: self.configurations.apiBaseUrl,
                             networkingService: self.internalNetworkingService)
    }()

    //----------------------------------------------------------------------------------------------
    // MARK: Begin Services */
    private var internalNetworkingService: NetworkingService = {
        return NetworkingServiceImpl()
    }()
    
    //----------------------------------------------------------------------------------------------
    // MARK: Begin Repository */
    
    private lazy var weatherRepository: WeatherRepository = {
        return WeatherRepositoryImpl(expireTime: self.configurations.cacheExpiredTime)
    }()
    
    //----------------------------------------------------------------------------------------------
    // MARK: Api */

    private lazy var forecastApi: ForecastApi = {
        return ForecastApiImpl(apiClient: self.apiClient,
                               transformer: self.forecastJsonTransformer.transform)
    }()
    
    //----------------------------------------------------------------------------------------------
    // MARK: Transformer */
    
    private lazy var forecastJsonTransformer: ForecastJsonTransformer = {
        return ForecastJsonTransformer(dayWeatherTransform: dayWeatherTransform)
    }()
    
    private lazy var dayWeatherTransform: DayWeatherTransform = {
        return DayWeatherTransform(dayTempTransform: dayTempTransform, weatherTransform: weatherTransform)
    }()
    
    private lazy var dayTempTransform: DayTempTransform = {
        return DayTempTransform()
    }()
    
    private lazy var weatherTransform: WeatherTransform = {
        return WeatherTransform()
    }()
    
    //----------------------------------------------------------------------------------------------
    // MARK: Interactor */

    static func weatherInteractor() -> WeatherInteractor {
        return WeatherInteractorImpl(forecastApi: instance.forecastApi,
                                     weatherRepository: instance.weatherRepository)
    }
}
