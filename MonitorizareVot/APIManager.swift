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
    func fetchPollingStations(then callback: @escaping ([PollingStationResponse]?, APIError?) -> Void)
    func fetchForms(then callback: @escaping ([FormResponse]?, APIError?) -> Void)
    func fetchForm(withId formId: Int,
                   then callback: @escaping ([FormSectionResponse]?, APIError?) -> Void)
    func upload(note: UploadNoteRequest,
                then callback: @escaping (APIError?) -> Void)
    func upload(answers: UploadAnswersRequest,
                then callback: @escaping (APIError?) -> Void)
}

enum APIError: Error {
    case unauthorized
    case incorrectFormat(reason: String?)
    case generic(reason: String?)
    case loginFailed(reason: String?)
    
    var localizedDescription: String {
        switch self {
        case .unauthorized: return "Error.TokenExpired".localized
        case .incorrectFormat(let reason): return "Error.IncorrectFormat".localized + " (\(reason ?? ""))"
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
            if let data = response.data {
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    if let token = loginResponse.accessToken {
                        AccountManager.shared.accessToken = token
                        callback(nil)
                    } else {
                        callback(.loginFailed(reason: loginResponse.error))
                    }
                } catch {
                    callback(.incorrectFormat(reason: error.localizedDescription))
                }
            } else {
                callback(.loginFailed(reason: "No data received"))
            }
        }
    }
    
    func fetchPollingStations(then callback: @escaping ([PollingStationResponse]?, APIError?) -> Void) {
        let url = ApiURL.pollingStationList.url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
            
                if response.response?.statusCode == 200,
                    let data = response.data {
                    do {
                        let response = try JSONDecoder().decode([PollingStationResponse].self, from: data)
                        callback(response, nil)
                    } catch {
                        callback(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if response.response?.statusCode == 401 {
                    callback(nil, .unauthorized)
                } else {
                    callback(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchForms(then callback: @escaping ([FormResponse]?, APIError?) -> Void) {
        let url = ApiURL.forms.url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
            
                if response.response?.statusCode == 200,
                    let data = response.data {
                    do {
                        let response = try JSONDecoder().decode(FormListResponse.self, from: data)
                        callback(response.forms, nil)
                    } catch {
                        callback(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if response.response?.statusCode == 401 {
                    callback(nil, .unauthorized)
                } else {
                    callback(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    func fetchForm(withId formId: Int,
                   then callback: @escaping ([FormSectionResponse]?, APIError?) -> Void) {
        let url = ApiURL.form(id: formId).url()
        let headers = authorizationHeaders()
        
        Alamofire
            .request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .response { response in
            
                if response.response?.statusCode == 200,
                    let data = response.data {
                    do {
                        let response = try JSONDecoder().decode([FormSectionResponse].self, from: data)
                        callback(response, nil)
                    } catch {
                        callback(nil, .incorrectFormat(reason: error.localizedDescription))
                    }
                } else if response.response?.statusCode == 401 {
                    callback(nil, .unauthorized)
                } else {
                    callback(nil, .incorrectFormat(reason: "Unknown reason"))
                }
        }
    }
    
    // TODO: test this
    func upload(note: UploadNoteRequest, then callback: @escaping (APIError?) -> Void) {
        let url = ApiURL.uploadNote.url()
        let headers = authorizationHeaders()
        
        let parameters: [String: String] = [
            "CountyCode": note.countyCode,
            "PollingStattionNumber": String(note.pollingStationId ?? -1),
            "QuestionId": String(note.questionId ?? -1),
            "Text": note.text
        ]
        let threshold = SessionManager.multipartFormDataEncodingMemoryThreshold
        
        Alamofire
            .upload(multipartFormData: { (multipart) in
                for (key, param) in parameters {
                    multipart.append(param.data(using: String.Encoding.utf8)!, withName: key)
                }
                if let imageData = note.imageData {
                    multipart.append(imageData, withName: "file", fileName: "newImage.jpg", mimeType: "image/jpeg")
                }
            }, usingThreshold: threshold, to: url, method: .post, headers: headers, encodingCompletion: { result in
                switch result {
                case .success(request: let request, streamingFromDisk: _, streamFileURL: _):
                    request.response { response in
                        if response.response?.statusCode == 200 {
                            callback(nil)
                        } else if response.response?.statusCode == 401 {
                            callback(.unauthorized)
                        } else {
                            callback(.incorrectFormat(reason: "Unknown reason"))
                        }
                    }
                case .failure(let error):
                    callback(.generic(reason: error.localizedDescription))
                }
        })
    }
    
    // TODO: test this
    func upload(answers: UploadAnswersRequest, then callback: @escaping (APIError?) -> Void) {
        let url = ApiURL.uploadAnswer.url()
        let headers = authorizationHeaders()
        let body = try! JSONEncoder().encode(answers)
        
        Alamofire
            .upload(body, to: url, method: .post, headers: headers)
            .response { response in
                if response.response?.statusCode == 200 {
                    callback(nil)
                } else if response.response?.statusCode == 401 {
                    callback(.unauthorized)
                } else {
                    callback(.incorrectFormat(reason: "Unknown reason"))
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
