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

typealias AnsweredFormSaverCompletion = () -> Void

class AnsweredFormSaver {
    private var completion: AnsweredFormSaverCompletion?
    
    func save(answeredForm: AnsweredForm, completion: @escaping AnsweredFormSaverCompletion) {
        self.completion = completion
        connectionState { (connected) in
            if connected {
                let url = APIURLs.Question.url
                let headers = ["Content-Type": "multipart/form-data"]
                var options = [[String: Any]]()
                for aAnswer in answeredForm.question.answers {
                    let option: [String: Any] = ["idOptiune" : aAnswer.id,
                                                    "selectata": aAnswer.selected,
                                                    "value": aAnswer.inputText ?? ""]
                    options.append(option)
                }
                let parameters: [String : Any] = ["idIntrebare": answeredForm.question.id,
                                                "codJudet": answeredForm.presidingOfficer.judet ?? "",
                                                "numarSectie": Int(answeredForm.presidingOfficer.sectie!) ?? -1,
                                                "codFormular": answeredForm.question.form,
                                                "optiuni": options]
                Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response:DataResponse<Any>) in
                    switch response.result {
                    case .success(_):
                        self.localSave(presidingOfficer: answeredForm.presidingOfficer, question: answeredForm.question, synced: true)
                    default:
                        self.localSave(presidingOfficer: answeredForm.presidingOfficer, question: answeredForm.question, synced: false)
                    }
                }
            } else {
                self.localSave(presidingOfficer: answeredForm.presidingOfficer, question: answeredForm.question, synced: false)
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
