//  Created by Code4Romania

import Foundation
import Alamofire
import SwiftKeychainWrapper

typealias FormsFetcherCompletion = (_ tokenExpired: Bool) -> Void

class FormsFetcher: FormFetcherDelegate {
    
    private var formsPersistor: FormsPersistor
    private var formsInformationsFetchers = [FormFetcher]()
    private var completion: FormsFetcherCompletion?
    
    init(formsPersistor: FormsPersistor) {
        self.formsPersistor = formsPersistor
    }
    
    func fetch(completion: @escaping FormsFetcherCompletion) {
        self.completion = completion
        let url = APIURLs.formsVersions.url
        if let token = KeychainWrapper.standard.string(forKey: "token") {
            let headers = ["Content-Type": "application/x-www-form-urlencoded",
                           "Authorization" :"Bearer " + token]
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                switch response.result {
                case .success(_):
                    if let data = response.result.value as? [String: AnyObject], let versionsInformations = data["versiune"] as? [String: AnyObject] {
                        for (aVersionKey, aVersionNumber) in versionsInformations {
                            if let aVersionNumber = aVersionNumber as? Int {
                                let version = self.formsPersistor.getVersion(forForm: aVersionKey)
                                if version < aVersionNumber {
                                    self.performFetchForForm(formName: aVersionKey, newVersion: aVersionNumber)
                                }
                            }
                        }
                    }
                    break
                default:
                    break
                }
            }
        } else {
            completion(true)
        }
    }
    
    private func performFetchForForm(formName: String, newVersion: Int) {
        let formFetcher = FormFetcher(form: formName, newVersion: newVersion)
        formFetcher.delegate = self
        formsInformationsFetchers.append(formFetcher)
        formFetcher.fetch {[weak self] (tokenExpired) in
            if let completion = self?.completion {
                completion(tokenExpired)
            }
        }
    }
    
    // MARK: - FormFetcherDelegate
    func didFinishRequest(fetcher: FormFetcher) {
        if let index = formsInformationsFetchers.firstIndex(where : { $0 == fetcher}) {
            if let informations = fetcher.informations {
                formsPersistor.save(version: fetcher.version, name: fetcher.formName, informations: informations)
            }
            formsInformationsFetchers.remove(at: index)
        }
    }
    
}
