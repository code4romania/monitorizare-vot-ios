//  Created by Code4Romania

import Foundation

enum QuestionType {
    case MultipleAnswer
    case SingleAnswer
    case SingleAnswerWithText
    case MultipleAnswerWithText

    func raw()-> Int {
        switch self {
        case .MultipleAnswer:
            return 0
        case .SingleAnswer:
            return 1
        case .SingleAnswerWithText:
            return 2
        case .MultipleAnswerWithText:
            return 3
        }
    }

}

struct MVQuestion {
    var form: String
    var id: Int
    var text: String
    var type: QuestionType
    var answered: NSAttributedString
    var answers: [MVAnswer]
    var synced: Bool
}

