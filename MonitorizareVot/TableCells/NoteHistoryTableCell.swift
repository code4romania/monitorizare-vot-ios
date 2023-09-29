//
//  NoteHistoryTableCell.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class NoteHistoryTableCell: UITableViewCell {
    
    static let reuseIdentifier = "NoteHistoryTableCell"
    override var reuseIdentifier: String? { return type(of: self).reuseIdentifier }
    
    @IBOutlet weak var outerContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView(frame: .zero)
        selectedBackgroundView?.backgroundColor = .clear
        selectionStyle = .none
        outerContainer.backgroundColor = .clear
        outerContainer.layer.shadowColor = UIColor.cardShadow.cgColor
        outerContainer.layer.shadowOffset = .zero
        outerContainer.layer.shadowRadius = UIConfiguration.shadowRadius
        outerContainer.layer.shadowOpacity = UIConfiguration.shadowOpacity
        cardContainer.layer.cornerRadius = UIConfiguration.buttonCornerRadius
        cardContainer.layer.masksToBounds = true
        detailsLabel.textColor = .defaultText
        dateLabel.textColor = .defaultText
        cardContainer.backgroundColor = .cardBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    func update(withModel model: NoteCellModel) {
        detailsLabel.text = model.text
        dateLabel.text = model.date
        layoutIfNeeded()
    }
    
}
