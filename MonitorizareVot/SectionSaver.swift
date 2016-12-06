//
//  SectionSaver.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 12/7/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

class SectionSaver {
    
    func save(presidingOfficer: MVPresidingOfficer, completion: AnsweredQuestionSaverCompletion?) {
        connectionState { (connected) in
            if connected {
                let url = APIURLs.section.url
                if let token = KeychainWrapper.standard.string(forKey: "token") {
                    let headers = ["Content-Type": "application/json",
                                   "Authorization" :"Bearer " + token]
                    
                    let params: [String : Any] = ["codJudet": presidingOfficer.judet!,
                                                   "numarSectie": presidingOfficer.sectie!,
                                                   "oraSosirii": presidingOfficer.arriveHour + ":" + presidingOfficer.arriveMinute,
                                                   "oraPlecarii": presidingOfficer.leftHour + ":" + presidingOfficer.leftMinute,
                                                   "esteZonaUrbana": presidingOfficer.medium! == "urban" ? true : false,
                                                   "presedinteBesvesteFemeie": presidingOfficer.genre! == "feminin" ? true : false ]
                    
                    Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseString(completionHandler: { (response) in
                        if let statusCode = response.response?.statusCode, statusCode == 200 {
                            completion?(false)
                        }
                    })
                }
            }
        }
    }

}
