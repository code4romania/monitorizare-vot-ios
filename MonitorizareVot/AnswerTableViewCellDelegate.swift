//  Created by Code4Romania

import Foundation

protocol AnswerTableViewCellDelegate: class {
    func didTapOnButton(answer: MVAnswer)
    func didChangeText(answer: MVAnswer, text: String)
}
