//  Created by Code4Romania

import Foundation

let baseUrlQA = "https://viuat.azurewebsites.net/api/v1"

enum APIURLs {
    case login
    case formsVersions
    case form
    case note
    case answeredQuestion
    case section
    
    var url: String {
        get {
            switch self {
            case .login:
                return baseUrlQA + "/access/token"
            case .formsVersions:
                return baseUrlQA + "/formular/versiune"
            case .form:
                return baseUrlQA + "/formular"
            case .note:
                return baseUrlQA + "/note/ataseaza"
            case .answeredQuestion:
                return baseUrlQA + "/raspuns"
            case .section:
                return baseUrlQA + "/sectie"
            }
        }
    }
}
