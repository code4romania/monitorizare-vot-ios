//
//  AnsweredFormSaver.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/21/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

typealias AnsweredQuestionSaverCompletion = () -> Void

class AnsweredQuestionSaver {
    private var completion: AnsweredQuestionSaverCompletion?
    
    func save(answeredQuestion: [AnsweredQuestion]) {
        for aAnsweredQuestion in answeredQuestion {
            save(answeredQuestion: aAnsweredQuestion, completion: nil)
        }
    }
    
    func save(answeredQuestion: AnsweredQuestion, completion: AnsweredQuestionSaverCompletion?) {
        self.completion = completion
        connectionState { (connected) in
            if connected {
                let url = APIURLs.AnsweredQuestion.url
                let headers = ["Content-Type": "application/json"]
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

                Alamofire.request(url, method: .post, parameters: ["raspuns": [raspuns]], encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                    switch response.result {
                    case .success(_):
                        self.localSave(presidingOfficer: answeredQuestion.presidingOfficer, question: answeredQuestion.question, synced: true)
                    default:
                        self.localSave(presidingOfficer: answeredQuestion.presidingOfficer, question: answeredQuestion.question, synced: false)
                    }
                }
            } else {
                self.localSave(presidingOfficer: answeredQuestion.presidingOfficer, question: answeredQuestion.question, synced: false)
            }
        }
    }
    
    private func localSave(presidingOfficer: PresidingOfficer, question: Question, synced: Bool) {
        var questionToSave = question
        questionToSave.synced = synced
        // to do:
        // save it locally
        // then call the completion
        completion?()
    }
    
}
