//  Created by Code4Romania

import Foundation
import UIKit

class QuestionCollectionViewCellConfigurator {
    func configure(form: String, cell: QuestionCollectionViewCell, with data: MVQuestion, row: Int) {
        cell.body.text = data.text
        cell.topLabel.text = form + String(row)
        cell.bottomLabel.attributedText = data.answered
    }
}
