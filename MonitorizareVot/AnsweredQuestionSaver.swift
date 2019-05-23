//  Created by Code4Romania

import Foundation
import Alamofire
import UIKit
import CoreData
import SwiftKeychainWrapper

class AnsweredQuestionSaver {
    private var completion: Completion?
    private var noteSaver = NoteSaver()
    
    var persistedSectionInfo: SectionInfo?
    var persistedQuestion: Question?
    
    func save(answeredQuestion: AnsweredQuestion, completion: Completion?) {
        self.completion = completion
        
        var localPersistedQuestion: Question
        if let persistedQuestion = persistedQuestion {
            localPersistedQuestion = persistedQuestion
        }
        else {
            let persistedQuestion = localSave(sectionInfo: persistedSectionInfo, existingQuestion:nil, question: answeredQuestion.question, synced: false)
            self.persistedQuestion = persistedQuestion
            localPersistedQuestion = persistedQuestion
        }
        noteSaver.noteContainer = localPersistedQuestion
        connectionState {[weak self] (connected) in
            if connected {
                if let note = answeredQuestion.question.note {
                    self?.noteSaver.save(note: note, completion: { (success, tokenExpired) in
                        self?.save(answeredQuestion: answeredQuestion, tokenExpired: tokenExpired)
                    })
                } else {
                    self?.save(answeredQuestion: answeredQuestion, tokenExpired: false)
                }
            }
            else {
                if let note = answeredQuestion.question.note {
                    self?.noteSaver.save(note: note, completion: { (success, tokenExpired) in
                        self?.completion?(true, false)
                    })
                } else {
                    self?.completion?(true, false)
                }
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
                var success = false
                var authFailed = false
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        if let question = self?.persistedQuestion {
                            self?.updateAsSynced(question: question)
                            success = true
                        }
                    } else if statusCode == 401 {
                        // unauthenticated
                        authFailed = true
                    }
                }
                self?.completion?(success, (tokenExpired || authFailed))
            })
        } else {
            self.completion?(true, true)
        }
    }
    
    
    private func localSave(sectionInfo: SectionInfo?, existingQuestion: Question?, question: MVQuestion, synced: Bool) -> Question {
        var questionToSave = question
        questionToSave.synced = synced
        
        var aQuestionToSave: Question
        if let existingQuestion = existingQuestion {
            aQuestionToSave = existingQuestion
        }
        else {
            aQuestionToSave = NSEntityDescription.insertNewObject(forEntityName: "Question", into: CoreData.context) as! Question
        }
        aQuestionToSave.setValue(question.id, forKey: "id")
        aQuestionToSave.setValue(question.answered, forKey: "answered")
        aQuestionToSave.setValue(question.form, forKey: "form")
        aQuestionToSave.setValue(synced, forKey: "synced")
        aQuestionToSave.setValue(question.text, forKey: "text")
        aQuestionToSave.setValue(question.type.raw(), forKey: "type")
        aQuestionToSave.setValue(sectionInfo, forKey: "sectionInfo")
        
        sectionInfo?.addToQuestions([aQuestionToSave])
        
        let answersMutableSet = NSMutableSet()
        for answer in question.answers {
            let answerToSave = NSEntityDescription.insertNewObject(forEntityName: "Answer", into: CoreData.context)
            answerToSave.setValue(answer.id, forKey: "id")
            answerToSave.setValue(answer.inputAvailable, forKey: "inputAvailable")
            answerToSave.setValue(answer.inputText, forKey: "inputText")
            answerToSave.setValue(answer.selected, forKey: "selected")
            answerToSave.setValue(answer.text, forKey: "text")
            answerToSave.setValue(aQuestionToSave, forKey: "question")
            answersMutableSet.add(answerToSave)
        }
        aQuestionToSave.answers = answersMutableSet.copy() as? NSSet
        try! CoreData.save()
        return aQuestionToSave
    }
    
    private func updateAsSynced(question: Question) {
        question.synced = true
        try! CoreData.save()
    }
    
}
