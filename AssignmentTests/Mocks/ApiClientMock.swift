//
//  ApiClientMock.swift
//  AssignmentTests
//
//  Created by azun on 25/03/2022.
//

import SwiftyJSON
import RxSwift

@testable import Assignment

class ApiClientMock<T>: ApiClient {
    
    var error: Error?
    var result: T?
    
    private var httpMethod: HTTPMethod!
    var requestedMethod: HTTPMethod {
        return httpMethod
    }
    
    private var url: String = ""
    var requestedUrl: String {
        return url
    }
    
    private var params: [String: Any]?
    var requestedParams: [String: Any]? {
        return params
    }
    
    func request<T>(_ method: HTTPMethod, url: String, needAuth: Bool = true,
                    fullUrl: Bool = false, parameters: [String: Any]?,
                    isJsonParams: Bool = true, errorHandler: ((Int, Error) -> Error)?,
                    parse: @escaping (JSON) -> T) -> Observable<T> {
        return request(method, url: url, needAuth: needAuth, fullUrl: fullUrl, parameters: parameters,
                       isJsonParams: isJsonParams, isBinary: false, contentType: nil,
                       errorHandler: errorHandler, parse: parse)
    }
    
    func get<T>(_ url: String, parameters: [String: Any]?,
                errorHandler: ((_ statusCode: Int, _ error: Error) -> Error)? = nil,
                parse: @escaping (_ data: JSON) -> T) -> Observable<T> {
        return request(.get, url: url, parameters: parameters, errorHandler: errorHandler, parse: parse)
    }

    func post<T>(_ url: String, parameters: [String: Any]?, isJsonParams: Bool,
                 errorHandler: ((_ statusCode: Int, _ error: Error) -> Error)? = nil,
                 parse: @escaping (_ data: JSON) -> T) -> Observable<T> {
        return request(.post, url: url, parameters: parameters, isJsonParams: isJsonParams,
                       errorHandler: errorHandler, parse: parse)
    }

    func post<T>(_ url: String, parameters: [String: Any]?,
                 errorHandler: ((_ statusCode: Int, _ error: Error) -> Error)? = nil,
                 parse: @escaping (_ data: JSON) -> T) -> Observable<T> {
        return post(url, parameters: parameters, isJsonParams: true, errorHandler: errorHandler, parse: parse)
    }

    func put<T>(_ url: String, parameters: [String: Any]?,
                errorHandler:((_ statusCode: Int, _ error: Error) -> Error)?,
                parse: @escaping (_ data: JSON) -> T) -> Observable<T> {
        return Observable.empty()
    }

    // swiftlint:disable:next function_parameter_count
    func upload<T>(_ url: String, file: Data, contentType: String, parameters: [String: Any]?,
                   progress: ((Float) -> Void)? = nil, errorHandler: ((Int, Error) -> Error)?,
                   parse: @escaping (JSON) -> T) -> Observable<T> {
        return Observable.empty()
    }

    func delete<T>(_ url: String, parameters: [String: Any]?,
                   errorHandler: ((Int, Error) -> Error)?, parse: @escaping (JSON) -> T) -> Observable<T> {
        return Observable.empty()
    }
    
    private func request<T>(_ method: HTTPMethod, url: String, needAuth: Bool = true, fullUrl: Bool = false,
                            parameters: [String: Any]?, isJsonParams: Bool = true,
                            isBinary: Bool, contentType: String?, progress: ((Float) -> Void)? = nil,
                            errorHandler: ((_ statusCode: Int, _ error: Error) -> Error)? = nil,
                            parse: @escaping (_ data: JSON) -> T) -> Observable<T> {
        
        httpMethod = method
        self.url = url
        params = parameters
        
        if let err = error,
           let errHandler = errorHandler {
            return Observable.error(errHandler(0, err))
        }
        
        if let theResult = result as? T {
            return Observable.just(theResult)
        }
        
        return Observable.error(ApiError.other(httpErrorCode: 0, statusCode: 0, description: "Unknown Error"))
    }
}
