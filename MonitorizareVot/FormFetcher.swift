//
//  FormFetcher.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/16/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import Alamofire

protocol FormFetcherDelegate: class {
    func didFinishRequest(fetcher: FormFetcher)
}

class FormFetcher {
    
    weak var delegate: FormFetcherDelegate?
    var formName: String
    var version: Int
    var informations: [[String :AnyObject]]?
    
    init(form: String, newVersion: Int) {
        formName = form
        version = newVersion
    }
    
    func fetch() {
        let url = APIURLs.Form.url
        let headers = ["Content-Type": "application/x-www-form-urlencoded"]
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
    }
}

func ==(left: FormFetcher, right: FormFetcher) -> Bool {
    return left.formName == right.formName
}
