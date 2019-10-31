//
//  QuestionTableCell.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 26/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class QuestionTableCell: UITableViewCell {
    
    static var identifier: String { return String(describing: self) }
    override var reuseIdentifier: String? { return type(of: self).identifier }
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var normalStateBg: UIView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var editIcon: UIImageView!
    @IBOutlet weak var checkIcon: UIImageView!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        normalStateBg.backgroundColor = .cardBackground
        normalStateBg.layer.cornerRadius = 4
        selectedView.backgroundColor = .cardBackgroundSelected
        selectedView.layer.cornerRadius = 4
        container.layer.shadowColor = UIColor.cardShadow.cgColor
        container.layer.shadowRadius = Configuration.shadowRadius
        container.layer.shadowOpacity = Configuration.shadowOpacity
        selectedBackgroundView = UIView(frame: .zero)
        selectedBackgroundView?.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        selectedView.alpha = selected ? 1 : 0
    }
    
    func update(withModel model: QuestionCellModel) {
        codeLabel.text = model.questionCode.uppercased()
        editIcon.isHidden = !model.hasNoteAttached
        checkIcon.isHidden = !model.isAnswered
        checkIcon.image = model.isSynced ? #imageLiteral(resourceName: "icon-check") : #imageLiteral(resourceName: "icon-check-greyed")
        questionTextLabel.text = model.questionText
    }
    
}
