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
        return getUnsyncedNotes().count + getUnsyncedQuestions().count > 0
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
    
    func getUnsyncedNotes() -> [Note] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let syncedPredicate = NSPredicate(format: "synced == false")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, syncedPredicate])
        let unsyncedNotes = CoreData.fetch(request) as? [Note]
        return unsyncedNotes ?? []
    }
    
    func getUnsyncedQuestions() -> [Question] {
        guard let section = currentSectionInfo() else { return [] }
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
    
    func getQuestion(withId id: Int) -> Question? {
        guard let section = currentSectionInfo() else { return nil }
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
    
    func setQuestionsSynced(withIds ids: [Int16]) {
        guard let section = currentSectionInfo() else { return }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "sectionInfo == %@", section)
        let formPredicate = NSPredicate(format: "id IN %@", ids)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, formPredicate])
        let unsyncedQuestions = CoreData.fetch(request) as? [Question] ?? []
        for question in unsyncedQuestions {
            question.synced = true
        }
        
        do {
            try CoreData.save()
        } catch {
            DebugLog("Error: couldn't save synced status locally: \(error)")
        }
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
