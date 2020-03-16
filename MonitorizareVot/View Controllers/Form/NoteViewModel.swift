//
//  NoteViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 31/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

/// This VM backs the note cells
struct NoteCellModel {
    var note: Note
    var text: String
    var date: String
    var isSynced: Bool
}

class NoteViewModel: NSObject {
    
    var questionId: Int?
    
    var notes: [NoteCellModel] = []
    
    init(withQuestionId questionId: Int? = nil) {
        self.questionId = questionId
        super.init()
        load()
    }
    
    func load() {
        notes = DB.shared.getNotes(attachedToQuestion: questionId).map { model(fromDbObject: $0) }
    }
    
    fileprivate func model(fromDbObject dbObject: Note) -> NoteCellModel {
        return NoteCellModel(note: dbObject,
                             text: dbObject.body ?? "",
                             date: DateFormatter.noteCell.string(from: dbObject.date ?? Date()),
                             isSynced: dbObject.synced)
    }
    
}
