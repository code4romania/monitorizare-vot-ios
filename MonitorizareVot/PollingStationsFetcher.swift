//
//  SectionFetcher.swift
//  MonitorizareVot
//
//  Created by Andrei Stanescu on 6/1/19.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

typealias PollingStationsFetcherCompletion = (_ tokenExpired: Bool, _ data: [[String:AnyObject]]?) -> Void

class PollingStationsFetcher {
    
    func fetch(completion: @escaping PollingStationsFetcherCompletion) {
        let url = APIURLs.pollingStation.url
        if let token = KeychainWrapper.standard.string(forKey: "token") {
            let headers = ["Content-Type": "application/json",
                           "Authorization" :"Bearer " + token]
            Alamofire.request(url, method: .get, parameters: nil, headers: headers).responseJSON { (response:DataResponse<Any>) in
                let pollingStations : [[String :AnyObject]]?
                
                switch response.result {
                case .success(_):
                    if let data = response.result.value as? [[String :AnyObject]] {
                        pollingStations = data
                    } else {
                        pollingStations = nil
                    }
                    break
                default:
                    pollingStations = nil
                    break
                }
                
                completion(false, pollingStations)
            }
        } else {
            completion(true, nil)
        }
    }
}
