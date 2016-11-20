//
//  LocalFormProvider.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/16/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

class LocalFormProvider: FormProvider {
    
    private var formsPersistor = LocalFormsPersistor()
    
    func getForm(named: String) -> Form? {
        if let formSections = formsPersistor.getInformations(forForm: named) {
            return createForm(informations: formSections, named: named)
        }
        return nil
    }
    
    
    private func createForm(informations: [[String: AnyObject]], named: String) -> Form {
        return Form(id: named, title: "Procedurile ...", sections: createSection(informations: informations))
    }
    
    private func createSection(informations: [[String: AnyObject]]) -> [Section] {
        var sections = [Section]()
        
        for aSection in informations {
            let code = aSection["codSectiune"] as! String
            let description = aSection["descriere"] as! String
            let questions = createQuestions(informations: aSection["intrebari"] as! [[String: AnyObject]])
            let newSection = Section(sectionCode: code, description: description, questions: questions)
            sections.append(newSection)
        }
        
        return sections
    }
    
    private func createQuestions(informations: [[String: AnyObject]]) -> [Question] {
        var questions = [Question]()
        for aQuestion in informations {
            let id = aQuestion["idIntrebare"] as! Int
            let text = aQuestion["textIntrebare"] as! String
            let questionID = aQuestion["idTipIntrebare"] as! Int
            let answers = createAnswers(informations: aQuestion["raspunsuriDisponibile"] as! [[String: AnyObject]])
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 11.0), NSForegroundColorAttributeName: MVColors.grey.color]
            let answered = NSAttributedString(string: "Necompletat", attributes: attributes)
            var type: QuestionType = .SingleAnswer
            
            if questionID == 0 {
                type = .MultipleAnswer
            } else if questionID == 1 {
                type = .SingleAnswer
            } else if questionID == 2 {
                type = .SingleAnswerWithText
            } else if questionID == 3 {
                type = .MultipleAnswerWithText
            }
            
            let newQuestion = Question(id: id, text: text, type: type, answered: answered,  answers: answers)
            questions.append(newQuestion)
        }
        return questions
    }
    
    private func createAnswers(informations: [[String: AnyObject]]) -> [Answer] {
        var answers = [Answer]()
        for aAnswer in informations {
            let id = aAnswer["idOptiune"] as! Int
            let text = aAnswer["textOptiune"] as! String
            let inputAvailable = aAnswer["seIntroduceText"] as! Bool
            let newAnswer = Answer(id: id, text: text, selected: false, inputAvailable: inputAvailable, inputText: nil)
            answers.append(newAnswer)
        }
        return answers
    }
}
