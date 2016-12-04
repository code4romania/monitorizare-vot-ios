//  Created by Code4Romania

import UIKit

class BasicAnswerTableViewCell: UITableViewCell, AnswerTableViewCell {
    
    @IBOutlet weak var button: UIButton!
    var answer: MVAnswer?
    weak var delegate: AnswerTableViewCellDelegate?
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapOnButton(answer: self.answer!)
    }
}
