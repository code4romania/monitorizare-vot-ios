//  Created by Code4Romania

import Foundation
import Alamofire
import UIKit
import CoreData
import SwiftKeychainWrapper

class AnsweredQuestionSaver {
    private var completion: Completion?
    private var noteSaver = NoteSaver()
    
    private let shouldTryToSaveLocallyIfFails: Bool
    
    init(shouldTryToSaveLocallyIfFails: Bool = true) {
        self.shouldTryToSaveLocallyIfFails = shouldTryToSaveLocallyIfFails
    }
    
    func save(answeredQuestion: [AnsweredQuestion]) {
        for aAnsweredQuestion in answeredQuestion {
            save(answeredQuestion: aAnsweredQuestion, completion: nil)
        }
    }
    
    func save(answeredQuestion: AnsweredQuestion, completion: Completion?) {
        self.completion = completion
        connectionState {[weak self] (connected) in
            if connected {
                if let note = answeredQuestion.question.note {
                    self?.noteSaver.save(note: note, completion: { (success, tokenExpired) in
                        self?.save(answeredQuestion: answeredQuestion, tokenExpired: tokenExpired)
                    })
                } else {
                    self?.save(answeredQuestion: answeredQuestion, tokenExpired: false)
                }
            } else {
                self?.localSave(sectionInfo: answeredQuestion.sectionInfo, question: answeredQuestion.question, synced: false, tokenExpired: false)
            }
        }
    }
    
    private func save(answeredQuestion: AnsweredQuestion, tokenExpired: Bool) {
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
                                           "codJudet": answeredQuestion.sectionInfo.judet ?? "",
                                           "numarSectie": answeredQuestion.sectionInfo.sectie ?? "-1",
                                           "codFormular": answeredQuestion.question.form,
                                           "optiuni": options]
            
            Alamofire.request(url, method: .post, parameters: ["raspuns": [raspuns]], encoding: JSONEncoding.default, headers: headers).responseString(completionHandler: {[weak self] (response) in
                if let statusCode = response.response?.statusCode, statusCode == 200 {
                    self?.localSave(sectionInfo: answeredQuestion.sectionInfo, question: answeredQuestion.question, synced: true, tokenExpired: (tokenExpired || false))
                } else {
                    self?.localSave(sectionInfo: answeredQuestion.sectionInfo, question: answeredQuestion.question, synced: false, tokenExpired: true)
                }
            })
        } else {
            self.localSave(sectionInfo: answeredQuestion.sectionInfo, question: answeredQuestion.question, synced: false, tokenExpired: true)
        }
    }
    
    
    private func localSave(sectionInfo: MVSectionInfo, question: MVQuestion, synced: Bool, tokenExpired: Bool) {
        var questionToSave = question
        questionToSave.synced = synced
        let sectionInfoToSave = NSEntityDescription.insertNewObject(forEntityName: "SectionInfo", into: CoreData.context)
        sectionInfoToSave.setValue(sectionInfo.arriveHour, forKey: "arriveHour")
        sectionInfoToSave.setValue(sectionInfo.arriveMinute, forKey: "arriveMinute")
        sectionInfoToSave.setValue(sectionInfo.genre, forKey: "genre")
        sectionInfoToSave.setValue(sectionInfo.judet, forKey: "judet")
        sectionInfoToSave.setValue(sectionInfo.sectie, forKey: "sectie")
        sectionInfoToSave.setValue(sectionInfo.synced, forKey: "synced")
        sectionInfoToSave.setValue(sectionInfo.leftHour, forKey: "leftHour")
        sectionInfoToSave.setValue(sectionInfo.leftMinute, forKey: "leftMinute")
        sectionInfoToSave.setValue(sectionInfo.medium, forKey: "medium")
        
        let aQuestionToSave = NSEntityDescription.insertNewObject(forEntityName: "Question", into: CoreData.context)
        aQuestionToSave.setValue(question.id, forKey: "id")
        aQuestionToSave.setValue(question.answered, forKey: "answered")
        aQuestionToSave.setValue(question.form, forKey: "form")
        aQuestionToSave.setValue(synced, forKey: "synced")
        aQuestionToSave.setValue(question.text, forKey: "text")
        aQuestionToSave.setValue(question.type.raw(), forKey: "type")
        aQuestionToSave.setValue(sectionInfoToSave, forKey: "sectionInfo")
        
        let questions = sectionInfoToSave.mutableSetValue(forKeyPath: "questions")
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
        completion?(true, false)
    }
    
}
