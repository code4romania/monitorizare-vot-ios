//
//  QuestionCollectionViewCell.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/17/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

class QuestionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - iVars
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layout()
    }
    
    // MARK: - Utils
    private func layout() {
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(colorLiteralRed:172.0/255.0, green:180.0/255.0, blue:190.0/255.0, alpha:1).cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 0.07
    }
}
