//
//  AnswerWithTextTableViewCell.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/19/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

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
        textView.placeholder = "Mai multe detalii ..."
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
