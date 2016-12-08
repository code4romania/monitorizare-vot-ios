//  Created by Code4Romania

import Foundation
import Alamofire
import UIKit
import CoreData
import SwiftKeychainWrapper

typealias AnsweredQuestionSaverCompletion = (_ tokenExpired: Bool) -> Void

class AnsweredQuestionSaver {
    private var completion: AnsweredQuestionSaverCompletion?
    
    private let shouldTryToSaveLocallyIfFails: Bool
    
    init(shouldTryToSaveLocallyIfFails: Bool = true) {
        self.shouldTryToSaveLocallyIfFails = shouldTryToSaveLocallyIfFails
    }
    
    func save(answeredQuestion: [AnsweredQuestion]) {
        for aAnsweredQuestion in answeredQuestion {
            save(answeredQuestion: aAnsweredQuestion, completion: nil)
        }
    }
    
    func save(answeredQuestion: AnsweredQuestion, completion: AnsweredQuestionSaverCompletion?) {
        self.completion = completion
        connectionState { (connected) in
            if connected {
                let url = APIURLs.answeredQuestion.url
                if let token = KeychainWrapper.standard.string(forKey: "token") {
                    let headers = ["Content-Type": "application/json",
                                   "Authorization" :"Bearer " + token]
                    var options = [[String: Any]]()
                    for aAnswer in answeredQuestion.question.answers {
                        if aAnswer.selected {
                            let option: [String: Any] = ["idOptiune" : aAnswer.id,
                                                            "value": aAnswer.inputText ?? ""]
                            options.append(option)
                        }
                    }
                    
                    let raspuns: [String : Any] = ["idIntrebare": answeredQuestion.question.id,
                                                    "codJudet": answeredQuestion.presidingOfficer.judet ?? "",
                                                    "numarSectie": answeredQuestion.presidingOfficer.sectie ?? "-1",
                                                    "codFormular": answeredQuestion.question.form,
                                                    "optiuni": options]

                    Alamofire.request(url, method: .post, parameters: ["raspuns": [raspuns]], encoding: JSONEncoding.default, headers: headers).responseString(completionHandler: {[weak self] (response) in
                        if let statusCode = response.response?.statusCode, statusCode == 200 {
                            self?.localSave(presidingOfficer: answeredQuestion.presidingOfficer, question: answeredQuestion.question, synced: true, tokenExpired: false)
                        } else {
                            self?.localSave(presidingOfficer: answeredQuestion.presidingOfficer, question: answeredQuestion.question, synced: false, tokenExpired: true)
                        }
                    })
                } else {
                   self.localSave(presidingOfficer: answeredQuestion.presidingOfficer, question: answeredQuestion.question, synced: false, tokenExpired: true)
                }
            } else {
                self.localSave(presidingOfficer: answeredQuestion.presidingOfficer, question: answeredQuestion.question, synced: false, tokenExpired: false)
            }
        }
    }
    
    private func savePresidingOfficerLocally() {
        
    }
    
    private func localSave(presidingOfficer: MVPresidingOfficer, question: MVQuestion, synced: Bool, tokenExpired: Bool) {
        var questionToSave = question
        questionToSave.synced = synced
        let presidingOfficerToSave = NSEntityDescription.insertNewObject(forEntityName: "PresidingOfficer", into: CoreData.context)
        presidingOfficerToSave.setValue(presidingOfficer.arriveHour, forKey: "arriveHour")
        presidingOfficerToSave.setValue(presidingOfficer.arriveMinute, forKey: "arriveMinute")
        presidingOfficerToSave.setValue(presidingOfficer.genre, forKey: "genre")
        presidingOfficerToSave.setValue(presidingOfficer.judet, forKey: "judet")
        presidingOfficerToSave.setValue(presidingOfficer.sectie, forKey: "sectie")
        presidingOfficerToSave.setValue(presidingOfficer.synced, forKey: "synced")
        presidingOfficerToSave.setValue(presidingOfficer.leftHour, forKey: "leftHour")
        presidingOfficerToSave.setValue(presidingOfficer.leftMinute, forKey: "leftMinute")
        presidingOfficerToSave.setValue(presidingOfficer.medium, forKey: "medium")
        
        let aQuestionToSave = NSEntityDescription.insertNewObject(forEntityName: "Question", into: CoreData.context)
        aQuestionToSave.setValue(question.id, forKey: "id")
        aQuestionToSave.setValue(question.answered.string, forKey: "answered")
        aQuestionToSave.setValue(question.form, forKey: "form")
        aQuestionToSave.setValue(synced, forKey: "synced")
        aQuestionToSave.setValue(question.text, forKey: "text")
        aQuestionToSave.setValue(question.type.raw(), forKey: "type")
        aQuestionToSave.setValue(presidingOfficerToSave, forKey: "presidingOfficer")
        
        let questions = presidingOfficerToSave.mutableSetValue(forKeyPath: "questions")
        questions.add(aQuestionToSave)
        
        for answer in question.answers {
            let answerToSave = NSEntityDescription.insertNewObject(forEntityName: "Answer", into: CoreData.context)
            answerToSave.setValue(answer.id, forKey: "id")
            answerToSave.setValue(answer.inputAvailable, forKey: "inputAvailable")
            answerToSave.setValue(answer.inputText, forKey: "inputText")
            answerToSave.setValue(answer.selected, forKey: "selected")
            answerToSave.setValue(answer.text, forKey: "text")
            answerToSave.setValue(aQuestionToSave, forKey: "question")
            let answers = aQuestionToSave.mutableSetValue(forKeyPath: "answers")
            answers.add(answerToSave)
        }
        try! CoreData.save()
        completion?(false)
    }
    
}
