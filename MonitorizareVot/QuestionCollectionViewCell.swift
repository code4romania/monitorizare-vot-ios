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
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var body: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layout()
    }
    
    // MARK: - Utils
    private func layout() {
        self.layer.dropDefaultShadow()
    }
}
