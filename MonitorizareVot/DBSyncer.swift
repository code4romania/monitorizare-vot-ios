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
    
    func  fetchPresidingOfficers() -> [MVPresidingOfficer] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "PresidingOfficer")
        let presidingOfficersArray = CoreData.fetch(request)
        var finalArray : [MVPresidingOfficer] = []
        for aPresdingOfficer in presidingOfficersArray {
            let finalOfficer = parsePresidingOfficer(presidingOfficer: aPresdingOfficer, withoutQuestions: false) as MVPresidingOfficer
            finalArray.append(finalOfficer)
        }
        return finalArray
    }
    
    func updateAnswersToServer() {
        answeredQuestionSaver = AnsweredQuestionSaver(shouldTryToSaveLocallyIfFails: false)
        let answeredDBQuestions = fetchQuestions()
        var answeredQuestionsToSave = [AnsweredQuestion]()
        for answeredDBQuestion in answeredDBQuestions {
            let questionToSync = AnsweredQuestion(question: answeredDBQuestion, presidingOfficer: answeredDBQuestion.presidingOfficer!)
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
        try! CoreData.context.save()
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
            var answered : String?
            var id: Int?
            if let questionId = aQuestion.value(forKey: "id") as? Int {
                id = questionId
            } else {
                id = 0
            }
            if let qAnswered = aQuestion.value(forKey: "answered") as? String {
                answered = qAnswered
            } else {
                answered = ""
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
            if let answered = answered, let id = id {
                if let presidingOfficerMO = aQuestion.value(forKey: "presidingOfficer") as? NSManagedObject {
                    let presidingOfficer = parsePresidingOfficer(presidingOfficer: presidingOfficerMO, withoutQuestions: true)
                    var q = MVQuestion(form: finalForm, id: id, text: finalText, type: QuestionType.SingleAnswer, answered: NSAttributedString(string: answered, attributes: nil), answers: [], synced: finalSynced, presidingOfficer: presidingOfficer, note: nil)
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
    
    public func parsePresidingOfficer(presidingOfficer: NSManagedObject, withoutQuestions: Bool) -> MVPresidingOfficer {
        let aPresidingOfficer = MVPresidingOfficer()
        if let arriveHour = presidingOfficer.value(forKey: "arriveHour") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = "00"
        }
        if let arriveMinute = presidingOfficer.value(forKey: "arriveMinute") as? String {
            aPresidingOfficer.arriveMinute = arriveMinute
        } else {
            aPresidingOfficer.arriveMinute = "00"
        }
        if let genre = presidingOfficer.value(forKey: "genre") as? String {
            aPresidingOfficer.genre = genre
        } else {
            aPresidingOfficer.arriveHour = ""
        }
        if let judet = presidingOfficer.value(forKey: "judet") as? String {
            aPresidingOfficer.judet = judet
        } else {
            aPresidingOfficer.judet = ""
        }
        if let sectie = presidingOfficer.value(forKey: "sectie") as? String {
            aPresidingOfficer.sectie = sectie
        } else {
            aPresidingOfficer.sectie = ""
        }
        if let medium = presidingOfficer.value(forKey: "medium") as? String {
            aPresidingOfficer.medium = medium
        } else {
            aPresidingOfficer.medium = ""
        }
        if let leftHour = presidingOfficer.value(forKey: "leftHour") as? String {
            aPresidingOfficer.leftHour = leftHour
        } else {
            aPresidingOfficer.leftHour = "00"
        }
        if let leftMinute = presidingOfficer.value(forKey: "leftMinute") as? String {
            aPresidingOfficer.leftMinute = leftMinute
        } else {
            aPresidingOfficer.leftMinute = "00"
        }
        if let questions = presidingOfficer.value(forKey: "questions") as? [NSManagedObject], !withoutQuestions {
            aPresidingOfficer.questions = parseQuestions(questionsToParse: questions)
        }
        return aPresidingOfficer
    }
    
    private func parseNotesFromDB(notesToParse: [NSManagedObject]) -> [MVNote] {
        var notes = [MVNote]()
        for  i in 0...notesToParse.count-1 {
            if let aNote = notesToParse[i] as? NSManagedObject {
//                var aPresidingOfficer = MVPresidingOfficer()
                if let presidingOfficer = aNote.value(forKey: "presidingOfficer") as? NSManagedObject{
                    let note = MVNote(presidingOfficer: parsePresidingOfficer(presidingOfficer: presidingOfficer, withoutQuestions: false))
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
