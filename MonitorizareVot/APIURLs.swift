//  Created by Code4Romania

import Foundation

enum APIURLs {
    case login
    @available(*, deprecated, message: "use `forms` instead")
    case formsVersions // deprecated
    case forms
    case form
    case note
    case answeredQuestion
    case section
    case pollingStation
    
    var url: String {
        get {
            switch self {
            case .login:
                return baseUrlQA + "/access/token"
            case .formsVersions:
                return baseUrlQA + "/formular/versiune"
            case .forms:
                return baseUrlQA + "/formular"
            case .form:
                return baseUrlQA + "/formular"
            case .note:
                return baseUrlQA + "/note/ataseaza"
            case .answeredQuestion:
                return baseUrlQA + "/raspuns"
            case .section:
                return baseUrlQA + "/sectie"
            case .pollingStation:
                return baseUrlQA + "/polling-station"
            }
        }
    }
    
    var baseUrlQA: String {
        if let info = Bundle.main.infoDictionary,
            let urlString = info["API_URL"] as? String {
            return urlString
        }
        return ""
    }
    

}
