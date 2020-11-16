//
//  DB.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation
import CoreData

class DB: NSObject {
    static let shared = DB()
    
    var needsSync: Bool {
        let unsyncedQuestions = getAllUnsyncedQuestions()
        let unsyncedNotes = getAllUnsyncedNotes()
        #if DEBUG
        // if debug mode, log how many sections have unsynced questions so we can test across all visited stations
        let sections = unsyncedQuestions.reduce(into: [SectionInfo]()) { (result, question) in
            if let info = question.sectionInfo {
                result.append(info)
            }
        }
        let set = NSSet(array: sections)
        DebugLog("Found \(unsyncedQuestions.count) unsynced questions in \(set.count) distinct polling stations.")
        #endif
        return unsyncedNotes.count
            + unsyncedQuestions.count > 0
    }
    
    func currentSectionInfo() -> SectionInfo? {
        guard let county = PreferencesManager.shared.county,
            let stationId = PreferencesManager.shared.section else { return nil }
        return sectionInfo(for: county, sectionId: stationId)
    }
    
    func sectionInfo(for county: String, sectionId: Int) -> SectionInfo {
        let request: NSFetchRequest<SectionInfo> = SectionInfo.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "countyCode == %@ && sectionId == %d", county, Int16(sectionId))
        let sections = try? CoreData.context.fetch(request)
        if let sectionInfo = sections?.first {
            return sectionInfo
        } else {
            // create it
            let sectionInfoEntityDescription = NSEntityDescription.entity(forEntityName: "SectionInfo", in: CoreData.context)
            let newSectioInfo = SectionInfo(entity: sectionInfoEntityDescription!, insertInto: CoreData.context)
            newSectioInfo.countyCode = county
            newSectioInfo.sectionId = Int16(sectionId)
            newSectioInfo.synced = false
            try! CoreData.context.save()
            return newSectioInfo
        }
    }
    
    /// - Returns: the list of unsynced notes across all visited stations
    func getAllUnsyncedNotes() -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "synced == false")
        let unsyncedNotes = CoreData.fetch(request) as? [Note]
        return unsyncedNotes ?? []
    }
    
    /// - Parameter section: the section
    /// - Returns: the list of unsynced notes in the specified section
    func getUnsyncedNotes(inSection section: SectionInfo) -> [Note] {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let syncedPredicate = NSPredicate(format: "synced == false")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, syncedPredicate])
        let unsyncedNotes = CoreData.fetch(request) as? [Note]
        return unsyncedNotes ?? []
    }
    
    /// - Returns: the list of unsynced questions across all stations
    func getAllUnsyncedQuestions() -> [Question] {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        request.predicate = NSPredicate(format: "synced == false")
        let unsyncedQuestions = CoreData.fetch(request) as? [Question]
        return unsyncedQuestions ?? []
    }
    
    /// - Parameter section: the section
    /// - Returns: the list of unsynced answers in the specified section
    func getUnsyncedQuestions(inSection section: SectionInfo) -> [Question] {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let syncedPredicate = NSPredicate(format: "synced == false")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, syncedPredicate])
        let unsyncedQuestions = CoreData.fetch(request) as? [Question]
        return unsyncedQuestions ?? []
    }
    
    func getQuestions(forForm formCode: String, formVersion: Int) -> [Question] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let formPredicate = NSPredicate(format: "form == %@", formCode)
        let formVersionPredicate = NSPredicate(format: "formVersion <= %d", Int16(formVersion))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, formPredicate, formVersionPredicate])
        let matchedQuestions = CoreData.fetch(request) as? [Question]
        return matchedQuestions ?? []
    }
    
    func delete(questions: [Question]) {
        let count = questions.count
        for question in questions {
            if let answers = question.answers,
                let all = answers.allObjects as? [Answer] {
                for answer in all {
                    CoreData.context.delete(answer)
                }
            }
            let notes = getNotes(attachedToQuestion: Int(question.id))
            for note in notes {
                CoreData.context.delete(note)
            }
            CoreData.context.delete(question)
            question.sectionInfo?.removeFromQuestions(question)
        }
        DebugLog("Deleted \(count) questions")
        try? CoreData.save()
    }
    
    func getQuestion(withId id: Int, inSection section: SectionInfo) -> Question? {
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let idPredicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, idPredicate])
        let matches = CoreData.fetch(request) as? [Question]
        return matches?.first
    }
    
    func getAnsweredQuestions(inFormWithCode formCode: String) -> [Question] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let formPredicate = NSPredicate(format: "form == %@", formCode)
        let answeredPredicate = NSPredicate(format: "answered == true")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, formPredicate, answeredPredicate])
        let unsyncedQuestions = CoreData.fetch(request) as? [Question]
        return unsyncedQuestions ?? []
    }
    
    /// Returns the list of all saved notes in this section. Optionally you can pass the questionId to return
    /// only the notes attached to that question. If nil, it will return all notes that aren't attached to any question
    /// - Parameter questionId: the question id
    func getNotes(attachedToQuestion questionId: Int?) -> [Note] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let questionPredicate = NSPredicate(format: "questionID == %d", Int16(questionId ?? -1))
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, questionPredicate])
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let notes = CoreData.fetch(request) as? [Note]
        return notes ?? []
    }
    
    func saveNote(withText text: String, fileAttachment: Data?, questionId: Int?) throws -> Note {
        let noteEntityDescription = NSEntityDescription.entity(forEntityName: "Note", in: CoreData.context)
        let note = Note(entity: noteEntityDescription!, insertInto: CoreData.context)
        note.body = text
        note.date = Date()
        note.questionID = Int16(questionId ?? -1)
        note.file = fileAttachment as NSData?
        note.synced = false
        note.sectionInfo = currentSectionInfo()
        try CoreData.save()
        return note
    }
    
}
