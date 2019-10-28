//
//  QuestionAnswerViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

struct QuestionAnswerCellModel {
    
    struct AnswerModel {
        var optionId: Int
        var isFreeText: Bool
        var text: String?
        var isSelected: Bool

        mutating func setIsSelected(_ selected: Bool) { isSelected = selected }
        mutating func setText(_ text: String?) { self.text = text }
    }
    
    var questionId: Int
    var questionCode: String
    var questionText: String
    var acceptsMultipleAnswers: Bool
    var questionAnswers: [AnswerModel]
    var isNoteAttached: Bool
    var isSaved: Bool
    var isSynced: Bool
    
    mutating func setIsNoteAttached(_ attached: Bool) { isNoteAttached = attached }
    mutating func setIsSaved(_ isSaved: Bool) { self.isSaved = isSaved }
    mutating func setIsSynced(_ isSynced: Bool) { self.isSynced = isSynced }
}

class QuestionAnswerViewModel: NSObject {
    fileprivate var form: FormResponse
    fileprivate var sections: [FormSectionResponse]
    
    var questions: [QuestionAnswerCellModel] = []
    var currentQuestionIndex: Int = 0
    
    init?(withFormUsingCode code: String, currentQuestionId: Int) {
        guard let form = LocalStorage.shared.getFormSummary(withCode: code),
            let sections = LocalStorage.shared.loadForm(withId: form.id) else { return nil }
        self.form = form
        self.sections = sections
        super.init()
        
        // initialize the models
        generateModels(usingFormSections: sections)
        setCurrentIndex(withQuestionId: currentQuestionId)
    }
    
    fileprivate func generateModels(usingFormSections formSections: [FormSectionResponse]) {
        guard let sectionInfo = DBSyncer.shared.currentSectionInfo else { return }
        let allQuestions = sections.reduce(into: [QuestionResponse]()) { $0 += $1.questions }
        
        let storedQuestions = sectionInfo.questions?.allObjects as? [Question] ?? []
        let mappedQuestions = storedQuestions.reduce(into: [Int: Question]()) { $0[Int($1.id)] = $1 }
        
        var models: [QuestionAnswerCellModel] = []
        for questionMeta in allQuestions {
            let answered = mappedQuestions[questionMeta.id]
            let options = questionMeta.options

            let acceptsMultipleAnswers = [
                QuestionResponse.QuestionType.multipleAnswers,
                QuestionResponse.QuestionType.multipleAnswerWithText]
                .contains(questionMeta.questionType)

            let storedAnswers = answered?.answers?.allObjects as? [Answer] ?? []
            let mappedAnswers = storedAnswers.reduce(into: [Int: Answer]()) { $0[Int($1.id)] = $1 }
            
            let isNoteAttached = answered?.note != nil

            var answerModels: [QuestionAnswerCellModel.AnswerModel] = []
            for optionMeta in options {
                let answer = mappedAnswers[optionMeta.id]
                let model = QuestionAnswerCellModel.AnswerModel(
                    optionId: optionMeta.id,
                    isFreeText: optionMeta.isFreeText,
                    text: answer?.text,
                    isSelected: answer?.selected == true)
                answerModels.append(model)
            }
            
            let model = QuestionAnswerCellModel(
                questionId: questionMeta.id,
                questionCode: questionMeta.code,
                questionText: questionMeta.text,
                acceptsMultipleAnswers: acceptsMultipleAnswers,
                questionAnswers: answerModels,
                isNoteAttached: isNoteAttached,
                isSaved: answered != nil,
                isSynced: answered?.synced == true)
            models.append(model)
        }
        self.questions = models
    }
    
    fileprivate func setCurrentIndex(withQuestionId questionId: Int) {
        currentQuestionIndex = questions.firstIndex(where: { $0.questionId == questionId }) ?? 0
    }
}
