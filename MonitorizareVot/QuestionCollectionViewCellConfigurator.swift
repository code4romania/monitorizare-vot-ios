//  Created by Code4Romania

import Foundation
import UIKit

class QuestionCollectionViewCellConfigurator {
    func configure(form: String, cell: QuestionCollectionViewCell, with data: MVQuestion, row: Int) {
        cell.body.text = data.text
        cell.topLabel.text = form + String(row)
        if data.answered {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 11.0), NSForegroundColorAttributeName: MVColors.green.color]
            cell.bottomLabel.attributedText = NSAttributedString(string: "Completat", attributes: attributes)
        } else {
            let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 11.0), NSForegroundColorAttributeName: MVColors.gray.color]
            cell.bottomLabel.attributedText = NSAttributedString(string: "Necompletat", attributes: attributes)
        }
    }
}
