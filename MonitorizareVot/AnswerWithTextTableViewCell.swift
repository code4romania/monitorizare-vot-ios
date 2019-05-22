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
        textViewBackground.layer.borderColor = UIColor.lightGray.cgColor
        textViewBackground.layer.borderWidth = 1
        textView.tintColor = UIColor.black
        generateInputView()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapOnButton(answer: answer!)
    }

    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        textView.resignFirstResponder()
    }
    
    // MARK: - MVUITextViewDelegate
    func textView(textView: MVUITextView, didChangeText: String) {
        delegate?.didChangeText(answer: answer!, text: didChangeText)
    }
    
    // MARK: - Helpers
    
    func generateInputView() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 44))
        view.autoresizingMask = [.flexibleWidth]
        view.backgroundColor = .black
        
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Button_Close".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(dismissButtonTapped(_:)), for: .touchUpInside)
        
        view.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 20).isActive = true
        view.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true

        textView.inputAccessoryView = view
    }
}
