//
//  ApiClientImpl.swift
//  F8
//
//  Created by Tuyen Nguyen Thanh on 10/12/16.
//  Copyright © 2016 Tuyen Nguyen Thanh. All rights reserved.
//

import Foundation
import RxSwift
import SwiftHTTP
import SwiftyJSON

class ApiClientImpl: ApiClient {
    private static let HeaderValueContentType = "application/vnd.mbc.v1+json;charset=UTF-8"
    private static let HeaderValueAuthorization = "Bearer %@"
    
    private static let HeaderKeyAccept = "Accept"
    private static let HeaderKeyContentType = "Content-Type"
    private static let HeaderKeyAuthorization = "Authorization"
    private static let HeaderKeyUserCountry = "userCountry"

    private let networkingService: NetworkingService
    
    let baseUrl: String

    init(baseUrl: String, networkingService: NetworkingService) {
        self.networkingService = networkingService

        self.baseUrl = baseUrl
    }

    func request<T>(_ method: HTTPMethod, url: String, needAuth: Bool = true,
                    fullUrl: Bool = false, parameters: [String: Any]?,
                    isJsonParams: Bool = true, errorHandler: ((Int, Error) -> Error)?,
                    parse: @escaping (JSON) -> T) -> Observable<T> {
        return request(method, url: url, needAuth: needAuth, fullUrl: fullUrl, parameters: parameters,
                       isJsonParams: isJsonParams, isBinary: false, contentType: nil,
                       errorHandler: errorHandler, parse: parse)
    }

    // swiftlint:disable:next function_parameter_count function_body_length
    private func request<T>(_ method: HTTPMethod, url: String, needAuth: Bool = true, fullUrl: Bool = false,
                            parameters: [String: Any]?, isJsonParams: Bool = true,
                            isBinary: Bool, contentType: String?, progress: ((Float) -> Void)? = nil,
                            errorHandler: ((_ statusCode: Int, _ error: Error) -> Error)? = nil,
                            parse: @escaping (_ data: JSON) -> T) -> Observable<T> {

        return networkingService.connected.take(1).flatMapLatest { connected -> Observable<T> in

            if !connected { throw NetworkError.networkNotAvailable }
            
            let requestedUrl = fullUrl ? url : self.baseUrl + url
            func createHTTPRequest(urlString: String, method: HTTPMethod, param: [String: Any]?,
                                   isBinary: Bool) -> HTTP {
                var headers = [ApiClientImpl.HeaderKeyAccept: ApiClientImpl.HeaderValueContentType]

                if isJsonParams { headers[ApiClientImpl.HeaderKeyContentType] = ApiClientImpl.HeaderValueContentType }

                var request: HTTP!
                switch method {
                case .get:
                    request = HTTP.New(requestedUrl, method: .GET,
                                       parameters: parameters, headers: headers,
                                       requestSerializer: JsonParamSerializer())
                case .post:
                    request = HTTP.New(requestedUrl, method: .POST,
                                       parameters: parameters, headers: headers,
                                       requestSerializer: JsonParamSerializer())
                case .delete:
                    request = HTTP.New(requestedUrl, method: .DELETE,
                                       parameters: parameters, headers: headers,
                                       requestSerializer: JsonParamSerializer())
                case .put:
                    if isBinary {
                        if contentType != nil {
                            headers = [ApiClientImpl.HeaderKeyContentType: contentType!]
                        }
                        request = HTTP.New(requestedUrl, method: .PUT,
                                           parameters: parameters, headers: headers,
                                           requestSerializer: BinaryParamSerializer())
                    } else {
                        request = HTTP.New(requestedUrl, method: .PUT,
                                           parameters: parameters, headers: headers,
                                           requestSerializer: JsonParamSerializer())
                    }
                }
                return request
            }

            return Observable.create { observer in

                let request = createHTTPRequest(urlString: requestedUrl, method: method,
                                                param: parameters, isBinary: isBinary)
                
                /// if API server's using a self-signed SSL cert, we may get an error due to iOS security
                /// (error domain=nsurlerrordomain code=-999 cancelled)
                /// temporary for QC and/or Staging. Please check if the Production server has the correct cert.
                /// https://github.com/daltoniam/SwiftHTTP/pull/39
                /// https://github.com/daltoniam/SwiftHTTP/commit/e28d05dd959b12d50d5ee7b5c9d4bd3819a7ff74
                var attempted = false
                request.auth = {(challenge: URLAuthenticationChallenge) in
                    if !attempted, let trusted = challenge.protectionSpace.serverTrust {
                        attempted = true
                        return URLCredential(trust: trusted)
                    }
                    return nil
                }
                
                if let uploadProgress = progress { request.progress = uploadProgress }

                request.run { [unowned self] response in
                    let responseUrl = response.URL?.absoluteString ?? ""

                    // Error case
                    if let error = response.error {

                        if let errorHandler = errorHandler,
                            let statusCode = response.statusCode,
                            let responseText = response.text,
                            let data = responseText.data(using: .utf8, allowLossyConversion: false) {
                            if let json = try? JSON(data: data) {
                                let error = self.parseError(url: responseUrl, statusCode: statusCode, json: json)
                                DispatchQueue.main.async { observer.onError(errorHandler(statusCode, error)) }
                                return
                            }
                        }

                        DispatchQueue.main.async { observer.onError(error) }
                        return
                    }

                    // Happy case
                    
                    let data = response.text!.data(using: .utf8, allowLossyConversion: false)!
                    if let json = try? JSON(data: data) {
                        if let statusCode = response.statusCode, statusCode != 200, statusCode != 201 {
                            let error = self.parseError(url: responseUrl, statusCode: statusCode, json: json)

                            if let errorHandler = errorHandler {
                                DispatchQueue.main.async { observer.onError(errorHandler(statusCode, error)) }
                                return
                            }
                            DispatchQueue.main.async { observer.onError(error) }
                            return
                        }

                        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                            let result = parse(json)

                            DispatchQueue.main.async {
                                observer.on(Event.next(result))
                                observer.on(Event.completed)
                            }
                        }
                    }
                }

                return Disposables.create { request.cancel() }
            }
            .retryWhen { (err: Observable<Error>) -> Observable<Void> in
                return err.flatMap { error -> Observable<Void> in
                    return Observable.error(error)
                }
            }
        }
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
        return request(.put, url: url, parameters: parameters, errorHandler: errorHandler, parse: parse)
    }

    // swiftlint:disable:next function_parameter_count
    func upload<T>(_ url: String, file: Data, contentType: String, parameters: [String: Any]?,
                   progress: ((Float) -> Void)? = nil, errorHandler: ((Int, Error) -> Error)?,
                   parse: @escaping (JSON) -> T) -> Observable<T> {
        var params: [String: Any] = [:]
        params["file"] = file
        return request(.put, url: url, fullUrl: true, parameters: params, isJsonParams: false, isBinary: true,
                       contentType: contentType, progress: progress, errorHandler: errorHandler, parse: parse)
    }

    func delete<T>(_ url: String, parameters: [String: Any]?,
                   errorHandler: ((Int, Error) -> Error)?, parse: @escaping (JSON) -> T) -> Observable<T> {
        return request(.delete, url: url, parameters: parameters, errorHandler: errorHandler, parse: parse)
    }

    fileprivate func parseError(url: String, statusCode: Int, json: JSON) -> ApiError {
        let code = json["code"].string ?? json["status"].stringValue
        let description = json["message"].stringValue

        switch statusCode {
        case 400:
            return ApiError.badRequest(description: description)
        case 401:
            return ApiError.authenticationFailure(description: description)
        case 403:
            return ApiError.forbidden(description: description)
        /*case 500:
            return ApiError.internalServerError(description: description)*/
        default:
            return ApiError.other(httpErrorCode: statusCode, statusCode: Int(code) ?? 500, description: description)
        }
    }
}

enum ApiError: Error {
    case badRequest(description: String) // 400
    case authenticationFailure(description: String) // 401
    case forbidden(description: String) // 403
    case internalServerError(description: String) // 500
    case other(httpErrorCode: Int, statusCode: Int, description: String)
    case dataNotAvailable(description: String)

    var description: String {
        switch self {
        case .badRequest(let description):
            return description
        case .authenticationFailure(let description):
            return description
        case .forbidden(let description):
            return description
        case .internalServerError(let description):
            return description
        case .other(_, _, let description):
            return description
        case .dataNotAvailable(let description):
            return description
        }
    }

    var httpErrorCode: Int {
        switch self {
        case .badRequest:
            return 400
        case .authenticationFailure:
            return 401
        case .forbidden:
            return 403
        case .internalServerError:
            return 500
        case .other(let httpErrorCode, _, _):
            return httpErrorCode
        case .dataNotAvailable:
            return -1000
        }
    }
    
    var statusCode: Int {
        switch self {
        case .other(_, let statusCode, _):
            return statusCode
        default:
            return httpErrorCode
        }
    }
}

enum NetworkError: Error {
    case networkNotAvailable
}
