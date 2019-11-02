//
//  AttachNoteViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 31/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum AttachNoteError: Error {
    case saveFailed
    case uploadFailed(reason: APIError)
    
    var localizedDescription: String {
        switch self {
        case .saveFailed: return "Error.SaveNoteFailed".localized
        case .uploadFailed(let reason): return "Error.UploadNoteFailed".localized + " (" + reason.localizedDescription + ")"
        }
    }
}

/// Any attachment that was added to this note
struct NoteAttachment {
    var filename: String
    var data: Data
}

class AttachNoteViewModel: NSObject {
    var questionId: Int?
    
    var text: String = "" {
        didSet {
            onUpdate?()
        }
    }
    var attachment: NoteAttachment? {
        didSet {
            onUpdate?()
        }
    }
    
    /// This is only present if the note has been saved or already exists
    var savedNote: Note?
    
    var canBeSaved: Bool {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).count > 2
    }
    
    var isSaved: Bool {
        return savedNote != nil
    }
    
    var isSynced: Bool {
        return savedNote?.synced == true
    }
    
    /// Subscribe to this to be notified whenever the model changes
    var onUpdate: (() -> Void)?
    
    init(withQuestionId questionId: Int? = nil) {
        self.questionId = questionId
        super.init()
    }
    
    init(withExistingNote note: Note) {
        self.savedNote = note
        self.questionId = Int(note.questionID)
        self.text = note.body ?? ""
        super.init()
    }
    
    func saveAndUpload(then callback: @escaping (AttachNoteError?) -> Void) {
        do {
            let note = try DB.shared.saveNote(withText: text, fileAttachment: attachment?.data, questionId: questionId)
            self.savedNote = note
            onUpdate?()
            print("Saved note locally")
        } catch {
            callback(.saveFailed)
            return
        }
        
        let pollingStation = DB.shared.currentSectionInfo()!
        let request = UploadNoteRequest(
            imageData: attachment?.data,
            questionId: questionId,
            countyCode: pollingStation.countyCode ?? "",
            pollingStationId: Int(pollingStation.sectionId),
            text: text)
        APIManager.shared.upload(note: request) { apiError in
            if let error = apiError {
                callback(.uploadFailed(reason: error))
                print("Note upload failed: \(error.localizedDescription)")
            } else {
                print("Uploaded note")
                
                self.savedNote?.synced = true
                try? CoreData.save()
                
                self.onUpdate?()
                callback(nil)
            }
        }
    }
}
