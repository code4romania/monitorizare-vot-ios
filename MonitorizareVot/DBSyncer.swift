//  Created by Code4Romania

import UIKit
import CoreData

class DBSyncer: NSObject {
    
    private let noteSaver = NoteSaver()

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
            let finalOfficer = parsePresidingOfficer(presidingOfficer: aPresdingOfficer) as MVPresidingOfficer
            finalArray.append(finalOfficer)
        }
        return finalArray
    }
    
    func fetchAnswers() -> [MVAnswer] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Answer")
        let answersToSyncArray = CoreData.fetch(request)
        let parsedAnswers = parseAnswers(answersToParse: answersToSyncArray)
        
        //POST answers & update synced value  
        
        
        return parsedAnswers
    }
    
    func updateAnswersToServer() {
        var answeredQuestionSaver = AnsweredQuestionSaver()
        var questionsToSend = fetchQuestions()
        var informatiiSectie = fetchPresidingOfficers()
        for sectie in informatiiSectie {
            
        }
    }
    
    func fetchQuestions() -> [MVQuestion] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Question")
        request.predicate = NSPredicate(format: "answered == true  && synced == false" )
        let questionsToSync = CoreData.fetch(request)
        let qustionsForUI = parseQuestions(questionsToParse: questionsToSync)
        return qustionsForUI
    }
    
    private func deleteSyncedNotes( notesToDelete: [NSManagedObject]) {
        for aNote in notesToDelete {
            CoreData.context.delete(aNote)
        }
    }
    
    private func parseAnswers(answersToParse: [NSManagedObject]) -> [MVAnswer] {
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
                let newAnswer = MVAnswer(id: id, text: text, selected: false, inputAvailable: input, inputText: nil)
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
            var answers : [MVAnswer] = []
            if let qAnswers = aQuestion.value(forKey: "answers") as? [NSManagedObject] {
                answers = parseAnswers(answersToParse: qAnswers)
            }
            if let answered = answered, let id = id {
                var q = MVQuestion(form: "", id: id, text: "", type: QuestionType.SingleAnswer, answered: NSAttributedString(string: answered, attributes: nil), answers: [], synced: false)
                q.answers = answers
                qArray.append(q)
            }
        }
        return qArray
    }
    
    public func parsePresidingOfficer(presidingOfficer: NSManagedObject) -> MVPresidingOfficer {
        let aPresidingOfficer = MVPresidingOfficer()
        if let arriveHour = presidingOfficer.value(forKey: "arriveHour") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = "00"
        }
        if let arriveHour = presidingOfficer.value(forKey: "arriveMinute") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = "00"
        }
        if let arriveHour = presidingOfficer.value(forKey: "genre") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = ""
        }
        if let arriveHour = presidingOfficer.value(forKey: "judet") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = ""
        }
        if let arriveHour = presidingOfficer.value(forKey: "sectie") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = ""
        }
        if let arriveHour = presidingOfficer.value(forKey: "medium") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = ""
        }
        if let arriveHour = presidingOfficer.value(forKey: "leftHour") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = "00"
        }
        if let arriveHour = presidingOfficer.value(forKey: "leftMinute") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = "00"
        }
        if let questionsArray = presidingOfficer.value(forKey: "questions") as? [NSManagedObject] {
            aPresidingOfficer.questions = parseQuestions(questionsToParse: questionsArray)
        }
        return aPresidingOfficer
    }
    
    private func parseNotesFromDB(notesToParse: [NSManagedObject]) -> [MVNote] {
        var notes = [MVNote]()
        for  i in 0...notesToParse.count-1 {
            if let aNote = notesToParse[i] as? NSManagedObject {
//                var aPresidingOfficer = MVPresidingOfficer()
                if let presidingOfficer = aNote.value(forKey: "presidingOfficer") as? NSManagedObject{
                    let note = MVNote(presidingOfficer: parsePresidingOfficer(presidingOfficer: presidingOfficer))
                if let body = aNote.value(forKey: "body") as? String {
                    note.body = body
                } else {
                    note.body = ""
                }
                if let file = aNote.value(forKey: "file") as? Data {
                    let image = UIImage(data: file)
                    note.image = image
                }
                if let questionID = aNote.value(forKey: "questionID") as? String {
                    note.questionID = questionID
                } else {
                    note.questionID = ""
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
