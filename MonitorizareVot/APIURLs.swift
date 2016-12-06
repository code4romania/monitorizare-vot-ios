//  Created by Code4Romania

import Foundation

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
                return "https://viuat.azurewebsites.net/api/v1/access/token"
            case .formsVersions:
                return "https://viuat.azurewebsites.net/api/v1/formular/versiune"
            case .form:
                return "https://viuat.azurewebsites.net/api/v1/formular"
            case .note:
                return "https://viuat.azurewebsites.net/api/v1/note/ataseaza"
            case .answeredQuestion:
                return "https://viuat.azurewebsites.net/api/v1/raspuns"
            case .section:
                return "https://viuat.azurewebsites.net/api/v1/sectie"
            }
        }
    }
}
