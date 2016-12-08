//  Created by Code4Romania

import UIKit
import CoreData

class DBSyncer: NSObject {
    
    private let noteSaver = NoteSaver()
    private var answeredQuestionSaver: AnsweredQuestionSaver?

    func fetchNotes() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.predicate = NSPredicate(format: "synced == false")
        let notesToSyncArray = CoreData.fetch(request)
        if notesToSyncArray.count >  0 {
            let notesForSaver = parseNotesFromDB(notesToParse: notesToSyncArray)
            noteSaver.save(notes: notesForSaver)
            self.deleteSyncedNotes(notesToDelete:notesToSyncArray)
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
    
    func updateAnswersToServer() {
        answeredQuestionSaver = AnsweredQuestionSaver(shouldTryToSaveLocallyIfFails: false)
        let answeredDBQuestions = fetchQuestions()
        var answeredQuestionsToSave = [AnsweredQuestion]()
        for answeredDBQuestion in answeredDBQuestions {
            let questionToSync = AnsweredQuestion(question: answeredDBQuestion, sectionInfo: answeredDBQuestion.sectionInfo!)
            answeredQuestionsToSave.append(questionToSync)
        }
        answeredQuestionSaver?.save(answeredQuestion: answeredQuestionsToSave)
    }
    
    private func fetchQuestions() -> [MVQuestion] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.predicate = NSPredicate(format: "synced == false")
        let questionsToSync = CoreData.fetch(request)
        let qustionsForUI = parseQuestions(questionsToParse: questionsToSync)
        for questionMO in questionsToSync {
            CoreData.context.delete(questionMO)
        }
        if questionsToSync.count > 0 {
            try! CoreData.context.save()
        }
        return qustionsForUI
    }
    
    private func deleteSyncedNotes( notesToDelete: [NSManagedObject]) {
        for aNote in notesToDelete {
            CoreData.context.delete(aNote)
        }
    }
    
    private func parseAnswers(answersToParse: Set<NSManagedObject>) -> [MVAnswer] {
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
    
    private func parseQuestions(questionsToParse: [NSManagedObject]) -> [MVQuestion] {
        var qArray : [MVQuestion] = []
        for aQuestion in questionsToParse {

            var id: Int?
            if let questionId = aQuestion.value(forKey: "id") as? Int {
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
        if let questions = sectionInfo.value(forKey: "questions") as? [NSManagedObject], !withoutQuestions {
            aSectionInfo.questions = parseQuestions(questionsToParse: questions)
        }
        return aSectionInfo
    }
    
    private func parseNotesFromDB(notesToParse: [NSManagedObject]) -> [MVNote] {
        var notes = [MVNote]()
        for  i in 0...notesToParse.count-1 {
            if let aNote = notesToParse[i] as? NSManagedObject {
//                var aSectionInfo = MVSectionInfo()
                if let sectionInfo = aNote.value(forKey: "sectionInfo") as? NSManagedObject{
                    let note = MVNote(sectionInfo: parseSectionInfo(sectionInfo: sectionInfo, withoutQuestions: false))
                if let body = aNote.value(forKey: "body") as? String {
                    note.body = body
                } else {
                    note.body = ""
                }
                if let file = aNote.value(forKey: "file") as? Data {
                    let image = UIImage(data: file)
                    note.image = image
                }
                if let questionID = aNote.value(forKey: "questionID") as? Int {
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
            }
        }
        return notes
    }
    
}
