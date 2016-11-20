//
//  Question.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/16/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

enum QuestionType {
    case MultipleAnswer
    case SingleAnswer
    case SingleAnswerWithText
    case MultipleAnswerWithText
}

struct Question {
    var id: Int
    var text: String
    var type: QuestionType
    var answered: NSAttributedString
    var answers: [Answer]
}
