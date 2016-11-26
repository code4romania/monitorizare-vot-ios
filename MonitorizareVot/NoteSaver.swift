//
//  NoteSaver.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/18/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

typealias NoteSaverCompletion = () -> Void

class NoteSaver {

    private var completion: NoteSaverCompletion?
    func save(notes: [Note]) {
        for aNote in notes {
            save(note: aNote, completion: nil)
        }
    }
    
    func save(note: Note, completion: NoteSaverCompletion?) {
        self.completion = completion
        connectionState { (connected) in
            if connected {
                let url = APIURLs.Note.url
                var imageData = Data()
                if let image = note.image {
                    imageData = UIImagePNGRepresentation(image)!
                }
                
                let parameters: [String : String] = ["CodJudet": note.presidingOfficer.judet ?? "",
                                "NumarSectie": note.presidingOfficer.sectie ?? "-1",
                                "IdIntrebare": note.questionID ?? "",
                                "TextNota": note.body ?? ""]
                
                Alamofire.upload(multipartFormData: { (multipart) in
                    for (aKey, aValue) in parameters {
                        multipart.append(aValue.data(using: String.Encoding.utf8)!, withName: aKey)
                    }
                    multipart.append(imageData, withName: "file", fileName: "newImage.png", mimeType: "image/png")
                    
                }, to: url, encodingCompletion: { (encodingResult) in
                    switch encodingResult {
                    case .success(request: let request, streamingFromDisk: _, streamFileURL: _):
                        request.responseJSON(completionHandler: { (response) in
                            if response.result.isSuccess {
                                if note.questionID != nil {
                                    self.localSave(note: note, synced: true)
                                }
                            }
                            self.localSave(note: note, synced: false)
                        })
                        
                    case .failure(_):
                        self.localSave(note: note, synced: false)
                    }
                })
            } else {
                self.localSave(note: note, synced: false)
            }
        }
    }
    
    private func savePresidingOfficer(presidingOfficer: PresidingOfficer) -> NSManagedObject {
        let presidingOfficerToSave = NSEntityDescription.insertNewObject(forEntityName: "PresidingOfficer", into: CoreData.context)
        presidingOfficerToSave.setValue(presidingOfficer.arriveHour, forKey: "arriveHour")
        presidingOfficerToSave.setValue(presidingOfficer.arriveMinute, forKey: "arriveMinute")
        presidingOfficerToSave.setValue(presidingOfficer.genre, forKey: "genre")
        presidingOfficerToSave.setValue(presidingOfficer.judet, forKey: "judet")
        presidingOfficerToSave.setValue(presidingOfficer.leftHour, forKey: "leftHour")
        presidingOfficerToSave.setValue(presidingOfficer.leftMinute, forKey: "leftMinute")
        presidingOfficerToSave.setValue(presidingOfficer.medium, forKey: "medium")
        return presidingOfficerToSave
    }
    
    private func localSave(note: Note, synced: Bool) {
        let noteToSave = NSEntityDescription.insertNewObject(forEntityName: "Note", into: CoreData.context);
        noteToSave .setValue(synced, forKey: "synced")
        noteToSave.setValue(note.questionID, forKey: "questionID")
        noteToSave.setValue(savePresidingOfficer(presidingOfficer: note.presidingOfficer), forKey: "presidingOfficer")
        noteToSave.setValue(note.body, forKey: "body")
        if let image = note.image, let imageData = UIImagePNGRepresentation(image) {
            noteToSave.setValue(imageData, forKey: "file")
        }
        try! CoreData.save()
        completion?()
    }
    
}
