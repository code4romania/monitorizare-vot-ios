//  Created by Code4Romania

import Foundation
import Alamofire
import SwiftKeychainWrapper

protocol FormFetcherDelegate: class {
    func didFinishRequest(fetcher: FormFetcher)
}

typealias FormFetcherCompletion = (_ tokenExpired: Bool) -> Void

class FormFetcher {
    
    weak var delegate: FormFetcherDelegate?
    var formName: String
    var version: Int
    var informations: [[String :AnyObject]]?
    
    init(form: String, newVersion: Int) {
        formName = form
        version = newVersion
    }
    
    func fetch(completion: FormFetcherCompletion) {
        let url = APIURLs.form.url
        if let token = KeychainWrapper.standard.string(forKey: "token") {
            let headers = ["Content-Type": "application/x-www-form-urlencoded",
                           "Authorization" :"Bearer " + token]
            Alamofire.request(url, method: .get, parameters: ["idformular": formName], headers: headers).responseJSON { (response:DataResponse<Any>) in
                switch response.result {
                case .success(_):
                    if let data = response.result.value as? [[String :AnyObject]] {
                        self.informations = data
                    }
                    break
                default:
                    break
                }
                self.delegate?.didFinishRequest(fetcher: self)
            }
        } else {
            completion(true)
        }
    }
}

func ==(left: FormFetcher, right: FormFetcher) -> Bool {
    return left.formName == right.formName
}
