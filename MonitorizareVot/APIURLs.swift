//
//  APIURLs.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/15/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

enum APIURLs {
    case Login
    case FormsVersions
    case Form

    var url: String {
        get {
            switch self {
            case .Login:
                return ""
            case .FormsVersions:
                return "https://viuat.azurewebsites.net/api/v1/formular/versiune"
            case .Form:
                return "https://viuat.azurewebsites.net/api/v1/formular"
            }
        }
    }
}
