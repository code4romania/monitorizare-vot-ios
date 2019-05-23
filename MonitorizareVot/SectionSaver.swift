//  Created by Code4Romania

import Foundation
import Alamofire
import SwiftKeychainWrapper
import CoreData

class SectionSaver {
    
    var persistedSectionInfo: SectionInfo?
    
    func save(sectionInfo: MVSectionInfo, completion: Completion?) {
        connectionState { (connected) in
            if connected {
                let url = APIURLs.section.url
                if let token = KeychainWrapper.standard.string(forKey: "token") {
                    let headers = ["Content-Type": "application/json",
                                   "Authorization" :"Bearer " + token]
                    var medium = ""
                    if let selectedMedium = sectionInfo.medium {
                        medium = selectedMedium
                    }
                    
                    var genre = ""
                    if let selectedGenre = sectionInfo.genre {
                        genre = selectedGenre
                    }
                        
                    let params: [String : Any] = ["codJudet": sectionInfo.judet!,
                                                   "numarSectie": sectionInfo.sectie!,
                                                   "oraSosirii": sectionInfo.arriveHour + ":" + sectionInfo.arriveMinute,
                                                   "oraPlecarii": sectionInfo.leftHour + ":" + sectionInfo.leftMinute,
                                                   "esteZonaUrbana": medium == "urban" ? true : false,
                                                   "presedinteBesvesteFemeie": genre == "woman" ? true : false ]
                    
                    Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseString(completionHandler: { (response) in
                        if let statusCode = response.response?.statusCode, statusCode == 200 {
                            self.markSectionAsSynced(sectionInfo: self.persistedSectionInfo)
                            completion?(true, false)
                        } else if let statusCode = response.response?.statusCode, statusCode == 401 {
                            completion?(false, true)
                        } else {
                            completion?(true, false)
                        }
                    })
                } else {
                    completion?(false, true)
                }
            } else {
                completion?(false, false)
            }
        }
    }

    private func markSectionAsSynced(sectionInfo: SectionInfo?) {
        if let sectionInfo = sectionInfo {
            sectionInfo.synced = true
            try! CoreData.save()
        }
    }
}
