//  Created by Code4Romania

import Foundation
import UIKit
import Alamofire

typealias LoginAPIRequestCompletion = (_ success: Bool, _ informations: Any?) -> Void

class LoginAPIRequest {
    
    private weak var parentView: UIViewController?
    
    init(parentView: UIViewController) {
        self.parentView = parentView
    }
    
    func perform(informations: [String: Any], completion: @escaping LoginAPIRequestCompletion) {
        if ReachabilityManager.shared.isReachable {
            let url = APIURLs.login.url
            let headers = ["Content-Type": "application/json"]
            Alamofire.request(url, method: .post, parameters: informations, encoding: JSONEncoding.default, headers: headers).responseString(completionHandler: { (response) in
                if let statusCode = response.response?.statusCode, statusCode == 200 {
                    let response = response.result.value
                    if let data = response?.data(using: .utf8) {
                        Logger.logAuthenticationWithSuccess(success: true, response: nil)
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any], let token = json["access_token"] as? String {
                                completion(true, token)
                            }
                        } catch {
                            completion(true, nil)
                        }
                    } else {
                        Logger.logAuthenticationWithSuccess(success: false, response: response)
                        completion(false, nil)
                    }
                } else {
                    Logger.logAuthenticationWithSuccess(success: false, response: response.result.value)
                    completion(false, nil)
                    let cancel = UIAlertAction(title: "Închide", style: .cancel, handler: nil)
                    
                    let alertController = UIAlertController(title: "Autentificarea a eșuat", message: "Datele introduse pentru autentificare nu sunt valide.", preferredStyle: .alert)
                    alertController.addAction(cancel)
                   self.parentView?.present(alertController, animated: true, completion: nil)
                }
            })
        } else {
            completion(false, nil)
            let cancel = UIAlertAction(title: "Închide", style: .cancel, handler: nil)
            
            let alertController = UIAlertController(title: "Eroare de conexiune", message: "Conectează-te la internet pentru a putea efectua autentificarea", preferredStyle: .alert)
            alertController.addAction(cancel)
            self.parentView?.present(alertController, animated: true, completion: nil)
        }
    }
    
}
