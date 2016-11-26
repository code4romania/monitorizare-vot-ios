//
//  NoteSaver.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/18/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import Alamofire

typealias NoteSaverCompletion = () -> Void

class NoteSaver {
    
    private var note: Note?
    private var completion: NoteSaverCompletion?
    
    func save(note: Note, completion: @escaping NoteSaverCompletion) {
        self.note = note
        self.completion = completion
        connectionState { (connected) in
            if connected {
                let url = APIURLs.Note.url
                var imageData = Data()
                if let image = note.image {
                    imageData = UIImagePNGRepresentation(image)!
                }
                
                let parameters: [String : String] = ["CodJudet": self.note!.presidingOfficer.judet ?? "",
                                "NumarSectie": self.note!.presidingOfficer.sectie ?? "-1",
                                "IdIntrebare": self.note!.questionID ?? "",
                                "TextNota": self.note!.body ?? ""]
                
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
                                self.localSave(note: note, synced: true)
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
    
    private func localSave(note: Note, synced: Bool) {
        let noteToSave = note
        noteToSave.synced = synced
        // to do:
        // save it locally
        // then call the completion
        completion?()
    }
    
}
