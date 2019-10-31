//
//  QuestionCollectionCell.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class QuestionCollectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "QuestionCollectionCell"
    override var reuseIdentifier: String? { return type(of: self).reuseIdentifier }
    
    var currentModel: QuestionAnswerCellModel?
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var statusContainer: UIStackView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var questionCodeLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var answersStackView: UIStackView!
    @IBOutlet weak var attachButton: AttachButton!
    
    typealias QuestionCollectionCellAnswerSelection = (_ model: inout QuestionAnswerCellModel, _ answerIndex: Int) -> Void
    
    typealias QuestionCollectionCellAddNote = (_ model: inout QuestionAnswerCellModel) -> Void
    
    /// Set this to be called back when the user taps an answer
    var onAnswerSelection: QuestionCollectionCellAnswerSelection?
    
    /// Set this to be called back when the user taps on Add Note
    var onAddNote: QuestionCollectionCellAddNote?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        container.layer.shadowColor = UIColor.cardDarkerShadow.cgColor
        container.layer.shadowRadius = Configuration.shadowRadius
        container.layer.shadowOpacity = 1
        container.layer.shadowOffset = .zero
    }

    func update(withModel model: QuestionAnswerCellModel) {
        currentModel = model
        questionCodeLabel.text = model.questionCode.uppercased()
        questionTextLabel.text = model.questionText
        
        answersStackView.arrangedSubviews.forEach {
            answersStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        for answer in model.questionAnswers {
            let button = ChooserButton(type: .custom)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            button.setContentCompressionResistancePriority(.required, for: .vertical)
            button.setContentHuggingPriority(.required, for: .vertical)
            button.setTitle(answer.text, for: .normal)
            if answer.isFreeText {
                let icon = answer.userText != nil ? #imageLiteral(resourceName: "icon-check") : nil
                button.setImage(icon, for: .normal)
            }
            button.isSelected = answer.isSelected
            button.addTarget(self, action: #selector(handleAnswerButtonTap(_:)), for: .touchUpInside)
            answersStackView.addArrangedSubview(button)
        }
        
        statusContainer.isHidden = !model.isSaved
        
        if model.isSynced {
            statusLabel.text = "Label_Synced".localized
            statusIcon.image = #imageLiteral(resourceName: "icon-check")
        } else if model.isSaved {
            statusLabel.text = "Label_Saved".localized
            statusIcon.image = #imageLiteral(resourceName: "icon-check-greyed")
        }
        
        attachButton.setTitle("Button_AddNoteToQuestion".localized, for: .normal)
        layoutIfNeeded()
    }
    
    @objc func handleAnswerButtonTap(_ button: UIButton) {
        guard currentModel != nil,
            let arrangedIndex = answersStackView.arrangedSubviews.firstIndex(of: button) else { return }
        onAnswerSelection?(&currentModel!, arrangedIndex)
    }
    
    @IBAction func handleAddNoteButtonTap(_ sender: Any) {
        guard currentModel != nil else { return }
        onAddNote?(&currentModel!)
    }
}
