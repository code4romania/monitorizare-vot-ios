//
//  LocalFormProvider.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/16/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

class LocalFormProvider: FormProvider {
    
    private var formsPersistor: FormsPersistor
    
    init(formsPersistor: FormsPersistor) {
        self.formsPersistor = formsPersistor
    }
    
    func getForm(named: String) -> Form? {
        if let formSections = formsPersistor.getInformations(forForm: named) {
            return createForm(informations: formSections, named: named)
        }
        return nil
    }
    
    
    private func createForm(informations: [[String: AnyObject]], named: String) -> Form {
        return Form(id: named, sections: createSection(informations: informations))
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
            let type = aQuestion["idTipIntrebare"] as! Int
            let answers = createAnswers(informations: aQuestion["raspunsuriDisponibile"] as! [[String: AnyObject]])
            let newQuestion = Question(id: id, text: text, type: type, answers: answers)
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
            let newAnswer = Answer(id: id, text: text, inputAvailable: inputAvailable)
            answers.append(newAnswer)
        }
        return answers
    }
}
