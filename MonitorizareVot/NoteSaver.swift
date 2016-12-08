//  Created by Code4Romania

import Foundation
import Alamofire
import CoreData
import SwiftKeychainWrapper

typealias Completion = (_ success: Bool, _ tokenExpired: Bool) -> Void

class NoteSaver {

    var noteContainer: NoteContainer?
    
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
                    imageData = UIImageJPEGRepresentation(image, 0.8)!
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
                        multipart.append(imageData, withName: "file", fileName: "newImage.jpg", mimeType: "image/jpeg")
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
    
    private func localSave(note: MVNote, synced: Bool, tokenExpired: Bool) {
        let noteToSave = NSEntityDescription.insertNewObject(forEntityName: "Note", into: CoreData.context) as! Note
        if let questionID = note.questionID {
            noteToSave.questionID = questionID//NSNumber(integerLiteral: Int(questionID))
        }
        noteToSave.synced = synced
        noteToSave.body = note.body
        if let image = note.image, let imageNSData = UIImageJPEGRepresentation(image, 0.8) {
            noteToSave.file = NSData(data: imageNSData)
        }
        noteContainer?.persist(note: noteToSave, in: CoreData.context)
        completion?(true, tokenExpired)
    }
    
}
