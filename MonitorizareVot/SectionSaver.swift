//  Created by Code4Romania

import Foundation
import Alamofire
import SwiftKeychainWrapper
import CoreData

class SectionSaver {
    
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
                                                   "presedinteBesvesteFemeie": genre == "feminin" ? true : false ]
                    
                    Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseString(completionHandler: { (response) in
                        if let statusCode = response.response?.statusCode, statusCode == 200 {
                            self.localUpdateSectie(sectionInfo: sectionInfo, synced: true)
                            completion?(true, false)
                        } else if let statusCode = response.response?.statusCode, statusCode == 401 {
                            
                        } else {
                            self.localUpdateSectie(sectionInfo: sectionInfo, synced: false)
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

    private func localSaveSectie(sectionInfo: MVSectionInfo, synced: Bool) {
        let infoSectie = NSEntityDescription.insertNewObject(forEntityName: "SectionInfo", into: CoreData.context)
        infoSectie.setValue(sectionInfo.judet, forKey: "judet")
        infoSectie.setValue(sectionInfo.sectie, forKey: "sectie")
        infoSectie.setValue(sectionInfo.arriveHour, forKey: "arriveHour")
        infoSectie.setValue(sectionInfo.arriveMinute, forKey: "arriveMinute")
        infoSectie.setValue(sectionInfo.leftHour, forKey: "leftHour")
        infoSectie.setValue(sectionInfo.leftMinute, forKey: "leftMinute")
        infoSectie.setValue(sectionInfo.genre, forKey: "genre")
        infoSectie.setValue(sectionInfo.medium, forKey: "medium")
        infoSectie.setValue(synced, forKey: "synced")
        try! CoreData.save()
    }
    
    func localUpdateSectie(sectionInfo: MVSectionInfo, synced: Bool) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SectionInfo")
        if let judet = sectionInfo.judet, let sectie = sectionInfo.sectie {
            request.predicate = NSPredicate(format: "judet == %@ && sectie == %@", judet, sectie)
        }
        let results = CoreData.fetch(request)
        if results.count > 0 {
            let dbSyncer = DBSyncer()
            localSaveSectie(sectionInfo: dbSyncer.parseSectionInfo(sectionInfo: results[0], withoutQuestions: false), synced: synced)
        }
    }

}
