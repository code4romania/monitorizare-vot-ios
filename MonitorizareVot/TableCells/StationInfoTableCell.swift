//
//  StationInfoTableCell.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/11/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class StationInfoTableCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var outerCardContainer: UIView!
    @IBOutlet weak var cardContainer: UIView!

    static let reuseIdentifier = "StationInfoTableCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
        contentView.clipsToBounds = false
        outerCardContainer.layer.shadowColor = UIColor.cardShadow.cgColor
        outerCardContainer.layer.shadowRadius = UIConfiguration.shadowRadius
        outerCardContainer.layer.shadowOpacity = UIConfiguration.shadowOpacity
        selectedBackgroundView = UIView(frame: .zero)
        selectedBackgroundView?.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        updateSelectionState(selected: selected)
    }
    
    fileprivate func updateSelectionState(selected: Bool) {
        cardContainer.backgroundColor = selected ?
            UIColor.cardBackgroundSelected : UIColor.cardBackground
    }
    
    func update(with model: VisitedStationModel) {
        nameLabel.text = model.name
    }
    
}
