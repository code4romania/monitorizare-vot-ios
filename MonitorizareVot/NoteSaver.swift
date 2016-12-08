//  Created by Code4Romania

import Foundation
import Alamofire
import CoreData
import SwiftKeychainWrapper

typealias Completion = (_ success: Bool, _ tokenExpired: Bool) -> Void

class NoteSaver {

    private var completion: Completion?
    func save(notes: [MVNote]) {
        for aNote in notes {
            save(note: aNote, completion: nil)
        }
    }
    
    func save(note: MVNote, completion: Completion?) {
        self.completion = completion
        connectionState { (connected) in
            if connected {
                let url = APIURLs.note.url
                var imageData = Data()
                if let image = note.image {
                    imageData = UIImagePNGRepresentation(image)!
                }
                
                var questionID = "-1"
                if let id = note.questionID {
                    questionID = String(id)
                }
                
                let parameters: [String: String] = ["CodJudet": note.sectionInfo.judet ?? "",
                                "NumarSectie": note.sectionInfo.sectie ?? "-1",
                                "IdIntrebare": questionID,
                                "TextNota": note.body ?? ""]
                
                if let token = KeychainWrapper.standard.string(forKey: "token") {
                    let headers = ["Authorization" :"Bearer " + token]
                    
                    Alamofire.upload(multipartFormData: { (multipart) in
                        for (aKey, aValue) in parameters {
                            multipart.append(aValue.data(using: String.Encoding.utf8)!, withName: aKey)
                        }
                        multipart.append(imageData, withName: "file", fileName: "newImage.png", mimeType: "image/png")
                    }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers, encodingCompletion: { (encodingResult) in
                        switch encodingResult {
                        case .success(request: let request, streamingFromDisk: _, streamFileURL: _):
                            request.responseString(completionHandler: {[weak self] (response) in
                                if let statusCode = response.response?.statusCode, statusCode == 200 {
                                    self?.localSave(note: note, synced: true, tokenExpired: false)
                                } else {
                                    self?.localSave(note: note, synced: false, tokenExpired: true)
                                }
                            })
                        case .failure(_):
                            self.localSave(note: note, synced: false, tokenExpired: false)
                        }
                    })
                } else {
                    self.localSave(note: note, synced: false, tokenExpired: true)
                }
            } else {
                self.localSave(note: note, synced: false, tokenExpired: false)
            }
        }
    }
    
    private func saveSectionInfo(sectionInfo: MVSectionInfo) -> NSManagedObject {
        let sectionInfoToSave = NSEntityDescription.insertNewObject(forEntityName: "SectionInfo", into: CoreData.context)
        sectionInfoToSave.setValue(sectionInfo.arriveHour, forKey: "arriveHour")
        sectionInfoToSave.setValue(sectionInfo.arriveMinute, forKey: "arriveMinute")
        sectionInfoToSave.setValue(sectionInfo.genre, forKey: "genre")
        sectionInfoToSave.setValue(sectionInfo.judet, forKey: "judet")
        sectionInfoToSave.setValue(sectionInfo.sectie, forKey: "sectie")
        sectionInfoToSave.setValue(sectionInfo.synced, forKey: "synced")
        sectionInfoToSave.setValue(sectionInfo.leftHour, forKey: "leftHour")
        sectionInfoToSave.setValue(sectionInfo.leftMinute, forKey: "leftMinute")
        sectionInfoToSave.setValue(sectionInfo.medium, forKey: "medium")
        return sectionInfoToSave
    }
    
    private func localSave(note: MVNote, synced: Bool, tokenExpired: Bool) {
        let noteToSave = NSEntityDescription.insertNewObject(forEntityName: "Note", into: CoreData.context)
        var questionID = "-1"
        if let id = note.questionID {
            questionID = String(id)
        }
        noteToSave .setValue(synced, forKey: "synced")
        noteToSave.setValue(questionID, forKey: "questionID")
        noteToSave.setValue(saveSectionInfo(sectionInfo: note.sectionInfo), forKey: "sectionInfo")
        noteToSave.setValue(note.body, forKey: "body")
        if let image = note.image, let imageData = UIImagePNGRepresentation(image) {
            noteToSave.setValue(imageData, forKey: "file")
        }
        try! CoreData.save()
        completion?(true, tokenExpired)
    }
    
}
