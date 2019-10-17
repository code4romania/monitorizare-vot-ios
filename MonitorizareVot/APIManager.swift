//
//  APIManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

protocol APIManagerType: NSObject {
    func login(withPhone phone: String,
               pin: String,
               then callback: @escaping (APIError?) -> Void)
    
    func fetchPollingStations(then callback: @escaping ([PollingStation]?, APIError?) -> Void)
}

enum APIError: Error {
    case unauthorized
    case incorrectFormat
    case generic(reason: String?)
    case loginFailed(reason: String?)
    
    var localizedDescription: String {
        switch self {
        case .unauthorized: return "Error.TokenExpired".localized
        case .incorrectFormat: return "Error.IncorrectFormat".localized
        case .generic(let reason): return reason ?? "Error_Unknown".localized
        case .loginFailed(let reason): return reason ?? "LoginError_Unknown".localized
        }
    }
}

class APIManager: NSObject, APIManagerType {
    static let shared: APIManagerType = APIManager()
    
    func login(withPhone phone: String, pin: String, then callback: @escaping (APIError?) -> Void) {
        let url = ApiURL.login.url()
        let udid = AccountManager.shared.udid
        let request = LoginRequest(user: phone, password: pin, uniqueId: udid)
        let parameters = encodableToParamaters(request)
        
        Alamofire
            .request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .response { response in
                
                if response.response?.statusCode == 400 {
                    if let data = response.data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            callback(.loginFailed(reason: errorResponse.error))
                            return
                        } catch {
                            callback(.incorrectFormat)
                        }
                    }
                    callback(.loginFailed(reason: nil))
                } else {
                    if let data = response.data,
                        let accessToken = String(data: data, encoding: .utf8) {
                        AccountManager.shared.accessToken = accessToken
                        callback(nil)
                        return
                    }
                    callback(.loginFailed(reason: nil))
                }
        }
    }
    
    func fetchPollingStations(then callback: @escaping ([PollingStation]?, APIError?) -> Void) {
        let url = ApiURL.pollingStationList.url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
            
                if response.response?.statusCode == 200,
                    let data = response.data {
                    do {
                        let response = try JSONDecoder().decode([PollingStation].self, from: data)
                        callback(response, nil)
                        return
                    } catch {
                        callback(nil, .incorrectFormat)
                    }
                } else if response.response?.statusCode == 401 {
                    callback(nil, .unauthorized)
                } else {
                    callback(nil, .incorrectFormat)
                }
        }
    }
    
}

// MARK: - Helpers

extension APIManager {
    fileprivate func encodableToParamaters<T: Encodable>(_ encodable: T) -> [String: Any] {
        let body = try! JSONEncoder().encode(encodable)
        return try! JSONSerialization.jsonObject(with: body, options: []) as! [String: Any]
    }
    
    fileprivate func authorizationHeaders() -> [String: String] {
        if let token = AccountManager.shared.accessToken {
            return ["Authorization": "Bearer " + token]
        } else {
            return [:]
        }
    }
}
