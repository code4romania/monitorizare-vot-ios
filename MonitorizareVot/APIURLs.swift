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
    case Note
    case Question
    
    var url: String {
        get {
            switch self {
            case .Login:
                return ""
            case .FormsVersions:
                return "https://viuat.azurewebsites.net/api/v1/formular/versiune"
            case .Form:
                return "https://viuat.azurewebsites.net/api/v1/formular"
            case .Note:
                return "https://viuat.azurewebsites.net/api/v1/note/ataseaza"
            case .Question:
                return "https://viuat.azurewebsites.net/api/v1/raspuns"
            }
        }
    }
}
