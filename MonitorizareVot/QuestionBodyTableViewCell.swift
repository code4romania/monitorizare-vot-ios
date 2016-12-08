//  Created by Code4Romania

import UIKit

class QuestionBodyTableViewCell: UITableViewCell {
    
    weak var delegate: ButtonHandler?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBAction func addNoteButtonPressed(_ sender: UIButton) {
        delegate?.didTapOnButton()
    }
    
}
