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
    case pollingStation
    case forms
    case form(id: Int)
    case uploadNote
    case uploadAnswer
    case registerToken

    func url() -> URL {
        var uri = ""
        switch self {
        case .login: uri = "/v1/access/authorize"
        case .pollingStationList: uri = "/v1/county"
        case .pollingStation: uri = "/v1/polling-station"
        case .forms: uri = "/v1/form"
        case .form(let id): uri = "/v1/form/\(id)"
        case .uploadNote: uri = "/v2/note/upload"
        case .uploadAnswer: uri = "/v1/answers"
        case .registerToken: uri = "/v1/notification/register"
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

