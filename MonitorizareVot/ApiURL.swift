//
//  ApiURL.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum ApiURL {
    case login
    case pollingStationList
    
    func url() -> URL {
        var uri = ""
        switch self {
        case .login: uri = "/access/authorize"
        case .pollingStationList: uri = "/polling-station"
        }
        return fullURL(withURI: uri)
    }
    
    private func fullURL(withURI uri: String) -> URL {
        guard let info = Bundle.main.infoDictionary,
            let urlString = info["API_URL"] as? String else {
            fatalError("No API_URL found")
        }
        guard let url = URL(string: urlString + uri) else {
            fatalError("Invalid url for provided uri: \(uri)")
        }
        return url
    }
}

struct LoginRequest: Codable {
    var user: String
    var password: String
    var uniqueId: String
}

struct ErrorResponse: Codable {
    var error: String
}

struct PollingStation: Codable {
    var id: Int
    var name: String
    var code: String
    var limit: Int
}

