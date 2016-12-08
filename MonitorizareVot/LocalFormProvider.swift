//  Created by Code4Romania

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
        return Form(id: named, title: "Procedurile ...", sections: createSection(informations: informations, named: named))
    }
    
    private func createSection(informations: [[String: AnyObject]], named: String) -> [MVSection] {
        var sections = [MVSection]()
        
        for aSection in informations {
            let description = aSection["descriere"] as! String
            let questions = createQuestions(informations: aSection["intrebari"] as! [[String: AnyObject]], named: named)
            let newSection = MVSection(sectionCode: named, description: description, questions: questions)
            sections.append(newSection)
        }
        
        return sections
    }
    
    private func createQuestions(informations: [[String: AnyObject]], named: String) -> [MVQuestion] {
        var questions = [MVQuestion]()
        for aQuestion in informations {
            let id = aQuestion["idIntrebare"] as! Int
            let text = aQuestion["textIntrebare"] as! String
            let questionID = aQuestion["idTipIntrebare"] as! Int
            let answers = createAnswers(informations: aQuestion["raspunsuriDisponibile"] as! [[String: AnyObject]])
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
            let newQuestion = MVQuestion(form: named, id: id, text: text, type: type, answered: false, answers: answers, synced: false, sectionInfo: nil, note: nil)
            questions.append(newQuestion)
        }
        return questions
    }
    
    private func createAnswers(informations: [[String: AnyObject]]) -> [MVAnswer] {
        var answers = [MVAnswer]()
        for aAnswer in informations {
            let id = aAnswer["idOptiune"] as! Int
            let text = aAnswer["textOptiune"] as! String
            let inputAvailable = aAnswer["seIntroduceText"] as! Bool
            let newAnswer = MVAnswer(id: id, text: text, selected: false, inputAvailable: inputAvailable, inputText: nil)
            answers.append(newAnswer)
        }
        return answers
    }
}
