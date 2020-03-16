//
//  NoteContainer.swift
//  MonitorizareVot
//
//  Created by Corneliu Chitanu on 08/12/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import CoreData

protocol NoteContainer {
    func persist(note: Note, in context: NSManagedObjectContext)
}

extension Question: NoteContainer {
    func persist(note: Note, in context: NSManagedObjectContext) {
        self.note = note
        note.questionID = self.id//NSNumber(integerLiteral: Int(self.id))
        try! context.save()
    }
}

extension SectionInfo: NoteContainer {
    func persist(note: Note, in context: NSManagedObjectContext) {
        self.addToNotes(note)
        note.sectionInfo = self
        try! context.save()
    }
}
