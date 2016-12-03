//
//  FormsFetcher.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/16/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import Alamofire

class FormsFetcher: FormFetcherDelegate {
    
    private var formsPersistor: FormsPersistor
    private var formsInformationsFetchers = [FormFetcher]()
    
    init(formsPersistor: FormsPersistor) {
        self.formsPersistor = formsPersistor
    }
    
    func fetch() {
        let url = APIURLs.FormsVersions.url
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
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
    }
    
    private func performFetchForForm(formName: String, newVersion: Int) {
        let formFetcher = FormFetcher(form: formName, newVersion: newVersion)
        formFetcher.delegate = self
        formsInformationsFetchers.append(formFetcher)
        formFetcher.fetch()
    }
    
    // MARK: - FormFetcherDelegate
    func didFinishRequest(fetcher: FormFetcher) {
        if let index = formsInformationsFetchers.index(where : { $0 == fetcher}) {
            if let informations = fetcher.informations {
                formsPersistor.save(version: fetcher.version, name: fetcher.formName, informations: informations)
            }
            print(index)
            formsInformationsFetchers.remove(at: index)
        }
    }
    
}
