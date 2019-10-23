//  Created by Code4Romania

import UIKit
import CoreData

class DBSyncer: NSObject {
    
    // TODO: test for concurrency issues on slow connections
    static let shared = DBSyncer()
    
    private var noteSavers = NSMapTable<NSNumber, NoteSaver>.strongToStrongObjects()
    private var answeredQuestionSavers = NSMapTable<NSNumber, AnsweredQuestionSaver>.strongToStrongObjects()
    
    func syncUnsyncedData() {
        syncUnsyncedNotes()
        syncUnsyncedQuestions()
    }
    
    func needsSync() -> Bool {
        return getUnsyncedNotes().count > 0
    }
    
    func getUnsyncedNotes() -> [Note] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SectionInfo")
        let allSectionInfo = CoreData.fetch(request) as! [SectionInfo]
        var notesToSyncArray = [Note]()
        for sectionInfo in allSectionInfo {
            if let notes = sectionInfo.notes?.allObjects {
                let unsyncedNotes = notes.filter({ (note: Any) -> Bool in
                    if let note = note as? Note {
                        return note.synced == false
                    }
                    else {
                        return false
                    }
                }) as! [Note]
                notesToSyncArray.append(contentsOf: unsyncedNotes)
            }
        }
        return notesToSyncArray
    }
    
    private func syncUnsyncedNotes() {
        let notesToSyncArray = getUnsyncedNotes()
        
        for noteIndex in 0 ..< notesToSyncArray.count {
            let noteToSave = notesToSyncArray[noteIndex]
            let sectionInfo = parseSectionInfo(sectionInfo: noteToSave.sectionInfo!, withoutQuestions: true)
            let noteForServer = parseNotesFromDB(notesToParse: [noteToSave], sectionInfo: sectionInfo).first!
            let noteSaver = NoteSaver()
            noteSaver.noteToSave = noteToSave
            let noteSaverKey = NSNumber(integerLiteral: noteIndex)
            noteSavers.setObject(noteSaver, forKey: noteSaverKey)
            noteSaver.save(note: noteForServer, completion: {[weak self] (success, tokenExpired) in
                self?.noteSavers.removeObject(forKey: noteSaverKey)
            })
        }
    }
    
    func sectionInfo(for judet: String, sectie:String) -> SectionInfo {
        let requestForExistingSectionInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "SectionInfo")
        requestForExistingSectionInfo.predicate = NSPredicate(format: "judet == %@ && sectie == %@", judet, sectie)
        let sectionInfoArray = CoreData.fetch(requestForExistingSectionInfo)
        if let sectionInfo = sectionInfoArray.first as? SectionInfo {
            return sectionInfo
        }
        else {
            let sectionInfoEntityDescription = NSEntityDescription.entity(forEntityName: "SectionInfo", in: CoreData.context)
            let newSectioInfo = SectionInfo(entity: sectionInfoEntityDescription!, insertInto: CoreData.context)
            newSectioInfo.judet = judet
            newSectioInfo.sectie = sectie
            newSectioInfo.synced = false
            try! CoreData.context.save()
            return newSectioInfo
        }
    }
    
    private func syncUnsyncedQuestions() {
        let answeredDBQuestions = fetchQuestions()
        for answeredDBQuestion in answeredDBQuestions {
            let questionForUI = parseQuestions(questionsToParse: [answeredDBQuestion]).first!
            let questionToSync = AnsweredQuestion(question: questionForUI, sectionInfo: questionForUI.sectionInfo!)
            let questionID = NSNumber(integerLiteral: Int(questionToSync.question.id))
            let answeredQuestionSaver = AnsweredQuestionSaver()
            answeredQuestionSaver.persistedQuestion = answeredDBQuestion
            answeredQuestionSavers.setObject(answeredQuestionSaver, forKey: questionID)
            answeredQuestionSaver.save(answeredQuestion: questionToSync, completion: {[weak self] (success, tokenExpired) in
                self?.answeredQuestionSavers.removeObject(forKey: questionID)
            })
        }
    }
    
    private func fetchQuestions() -> [Question] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.predicate = NSPredicate(format: "synced == false")
        let questionsToSync = CoreData.fetch(request) as! [Question]
        return questionsToSync
    }
    
    private func deleteSyncedNotes( notesToDelete: [NSManagedObject]) {
        for aNote in notesToDelete {
            CoreData.context.delete(aNote)
        }
    }
    
    func parseAnswers(answersToParse: Set<NSManagedObject>) -> [MVAnswer] {
        var answersArray : [MVAnswer] = []
        for anAnswer in answersToParse {
            var id : Int?
            var text : String?
            var input : Bool?
            if let anId = anAnswer.value(forKey: "id") {
                id = anId as? Int
            }
            if let aText = anAnswer.value(forKey: "text") {
                text = aText as? String
            }
            if let anInput = anAnswer.value(forKey: "inputAvailable") {
                input = anInput as? Bool
            }
            if let id = id, let text = text, let input = input {
                var newAnswer = MVAnswer(id: id, text: text, selected: false, inputAvailable: input, inputText: nil)
                if let selected = anAnswer.value(forKey: "selected") as? Bool {
                    newAnswer.selected = selected
                }
                if let inputText = anAnswer.value(forKey: "inputText") as? String {
                    newAnswer.inputText = inputText
                }
                answersArray.append(newAnswer)
            }
        }
        return answersArray
    }
    
    func parseQuestions(questionsToParse: [Question]) -> [MVQuestion] {
        var qArray : [MVQuestion] = []
        for aQuestion in questionsToParse {

            var id: Int16?
            if let questionId = aQuestion.value(forKey: "id") as? Int16 {
                id = questionId
            } else {
                id = 0
            }
            
            var answered = false
            if let qAnswered = aQuestion.value(forKey: "answered") as? Bool {
                answered = qAnswered
            }
            
            var finalForm: String
            if let form = aQuestion.value(forKey: "form") as? String {
                finalForm = form
            } else {
                finalForm = ""
            }
            var finalText: String
            if let text = aQuestion.value(forKey: "text") as? String {
                finalText = text
            } else {
                finalText = ""
            }
            var finalSynced: Bool
            if let synced = aQuestion.value(forKey: "synced") as? Bool {
                finalSynced = synced
            } else {
                finalSynced = false
            }
            var answers : [MVAnswer] = []
            if let qAnswers = aQuestion.value(forKey: "answers") as? Set<NSManagedObject> {
                answers = parseAnswers(answersToParse: qAnswers)
            }
            
            if let id = id {
                if let sectionInfoMO = aQuestion.value(forKey: "sectionInfo") as? NSManagedObject {
                    let sectionInfo = parseSectionInfo(sectionInfo: sectionInfoMO, withoutQuestions: true)
                    var q = MVQuestion(form: finalForm, id: id, text: finalText, type: QuestionType.SingleAnswer, answered: answered, answers: [], synced: finalSynced, sectionInfo: sectionInfo, note: nil)
                    if let type = aQuestion.value(forKey: "type") as? Int {
                        q.type = QuestionType(dbValue: type)
                    }
                    if let type = aQuestion.value(forKey: "type") as? Int {
                        q.type = QuestionType(dbValue: type)
                    }
                    q.answers = answers
                    if let note = aQuestion.note {
                        let parsedNote = parseNotesFromDB(notesToParse: [note], sectionInfo: sectionInfo).first!
                        q.note = parsedNote
                    }
                    qArray.append(q)
                }
            }
        }
        return qArray
    }
    
    public func parseSectionInfo(sectionInfo: NSManagedObject, withoutQuestions: Bool) -> MVSectionInfo {
        let aSectionInfo = MVSectionInfo()
        if let arriveHour = sectionInfo.value(forKey: "arriveHour") as? String {
            aSectionInfo.arriveHour = arriveHour
        } else {
            aSectionInfo.arriveHour = "00"
        }
        if let arriveMinute = sectionInfo.value(forKey: "arriveMinute") as? String {
            aSectionInfo.arriveMinute = arriveMinute
        } else {
            aSectionInfo.arriveMinute = "00"
        }
        if let genre = sectionInfo.value(forKey: "genre") as? String {
            aSectionInfo.genre = genre
        } else {
            aSectionInfo.arriveHour = ""
        }
        if let judet = sectionInfo.value(forKey: "judet") as? String {
            aSectionInfo.judet = judet
        } else {
            aSectionInfo.judet = ""
        }
        if let sectie = sectionInfo.value(forKey: "sectie") as? String {
            aSectionInfo.sectie = sectie
        } else {
            aSectionInfo.sectie = ""
        }
        if let medium = sectionInfo.value(forKey: "medium") as? String {
            aSectionInfo.medium = medium
        } else {
            aSectionInfo.medium = ""
        }
        if let leftHour = sectionInfo.value(forKey: "leftHour") as? String {
            aSectionInfo.leftHour = leftHour
        } else {
            aSectionInfo.leftHour = "00"
        }
        if let leftMinute = sectionInfo.value(forKey: "leftMinute") as? String {
            aSectionInfo.leftMinute = leftMinute
        } else {
            aSectionInfo.leftMinute = "00"
        }
        if let questions = sectionInfo.value(forKey: "questions") as? [Question], !withoutQuestions {
            aSectionInfo.questions = parseQuestions(questionsToParse: questions)
        }
        return aSectionInfo
    }
    
    func parseNotesFromDB(notesToParse: [Note], sectionInfo: MVSectionInfo) -> [MVNote] {
        var notes = [MVNote]()
        for  i in 0 ..< notesToParse.count {
            let aNote = notesToParse[i]
            let note = MVNote(sectionInfo: sectionInfo)
            if let body = aNote.value(forKey: "body") as? String {
                note.body = body
            } else {
                note.body = ""
            }
            if let file = aNote.value(forKey: "file") as? Data {
                let image = UIImage(data: file)
                note.image = image
            }
            if let questionID = aNote.value(forKey: "questionID") as? Int16 {
                note.questionID = questionID
            } else {
                note.questionID = -1
            }
            if let synced = aNote.value(forKey: "synced") as? Bool {
                note.synced = synced
            } else {
                note.synced = false
            }
            notes.append(note)
        }
        return notes
    }
    
}
