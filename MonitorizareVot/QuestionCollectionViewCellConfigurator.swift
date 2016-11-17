//
//  QuestionCollectionViewCellConfigurator.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/17/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

class QuestionCollectionViewCellConfigurator {
    func configure(form: String, cell:QuestionCollectionViewCell, with data: Question, row: Int) {
        cell.body.text = data.text
        cell.topLabel.text = form + String(row)
        cell.bottomLabel.attributedText = data.answered
    }
}
