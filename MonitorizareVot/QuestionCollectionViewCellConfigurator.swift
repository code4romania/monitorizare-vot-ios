//  Created by Code4Romania

import Foundation
import UIKit

class QuestionCollectionViewCellConfigurator {
    func configure(form: String, cell: QuestionCollectionViewCell, with data: MVQuestion, row: Int) {
        cell.body.text = data.text
        cell.topLabel.text = form + String(row)
        if data.answered {
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11.0), NSAttributedString.Key.foregroundColor: MVColors.green.color]
            cell.bottomLabel.attributedText = NSAttributedString(string: "Label_Completed".localized, attributes: attributes)
        } else {
            let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11.0), NSAttributedString.Key.foregroundColor: MVColors.gray.color]
            cell.bottomLabel.attributedText = NSAttributedString(string: "Label_NotCompleted".localized, attributes: attributes)
        }
    }
}
