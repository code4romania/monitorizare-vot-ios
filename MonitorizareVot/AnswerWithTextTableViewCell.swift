//  Created by Code4Romania

import UIKit

class AnswerWithTextTableViewCell: UITableViewCell, AnswerTableViewCell, MVUITextViewDelegate {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textView: MVUITextView!
    @IBOutlet weak var textViewBackground: UIView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!

    var answer: MVAnswer?
    weak var delegate: AnswerTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.placeholder = "TextView_Placeholder_MoreDetails".localized
        textView.customDelegate = self
        textViewBackground.layer.defaultCornerRadius(borderColor: MVColors.gray.color.cgColor)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapOnButton(answer: answer!)
    }

    // MARK: - MVUITextViewDelegate
    func textView(textView: MVUITextView, didChangeText: String) {
        delegate?.didChangeText(answer: answer!, text: didChangeText)
    }
}
