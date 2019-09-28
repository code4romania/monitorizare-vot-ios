//  Created by Code4Romania

import Foundation
import UIKit

class AnswerWithTextTableViewCellConfigurator {
    
    func configure(cell: AnswerWithTextTableViewCell, answer: MVAnswer, delegate: AnswerTableViewCellDelegate, selected: Bool) -> UITableViewCell {
        cell.delegate = delegate
        cell.button.setTitle(answer.text, for: .normal)
        cell.button.setTitleColor(MVColors.black.color, for: .normal)
        cell.button.layer.defaultCornerRadius(borderColor: MVColors.gray.color.cgColor)
        cell.button.layer.dropDefaultShadow()
        cell.textView.savedText = answer.inputText
        cell.answer = answer

        if selected {
            cell.button.backgroundColor = MVColors.yellow.color
            cell.textViewHeight.constant = 150
        } else {
            cell.button.backgroundColor = MVColors.white.color
            cell.textViewHeight.constant = 0
        }
        
        return cell
    }
}
