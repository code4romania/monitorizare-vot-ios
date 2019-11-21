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
        return text.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
    }

    var isSaving: Bool = false {
        didSet {
            onUpdate?()
        }
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
    
    fileprivate func reset() {
        text = ""
        attachment = nil
    }
    
    func saveAndUpload(then callback: @escaping (AttachNoteError?) -> Void) {
        isSaving = true
        
        do {
            let note = try DB.shared.saveNote(withText: text, fileAttachment: attachment?.data, questionId: questionId)
            self.savedNote = note
            onUpdate?()
            DebugLog("Saved note locally")
        } catch {
            isSaving = false
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
        
        if let questionId = questionId {
            MVAnalytics.shared.log(event: .addNoteForQuestion(questionId: questionId, hasAttachment: attachment != nil))
        } else {
            MVAnalytics.shared.log(event: .addNote(hasAttachment: attachment != nil))
        }
        
        APIManager.shared.upload(note: request) { apiError in
            if let error = apiError {
                self.isSaving = false
                callback(.uploadFailed(reason: error))
                DebugLog("Note upload failed: \(error.localizedDescription)")
            } else {
                DebugLog("Uploaded note")
                
                self.savedNote?.synced = true
                try? CoreData.save()
                
                self.reset()
                
                self.isSaving = false
                self.onUpdate?()
                callback(nil)
            }
        }
    }
}
