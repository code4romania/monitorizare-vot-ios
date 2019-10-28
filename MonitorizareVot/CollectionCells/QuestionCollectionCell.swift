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
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var questionCodeLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var answersStackView: UIStackView!
    @IBOutlet weak var attachButton: AttachButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
