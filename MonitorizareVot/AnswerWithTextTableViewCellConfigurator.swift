//
//  AnswerWithTextTableViewCellConfigurator.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/19/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

class AnswerWithTextTableViewCellConfigurator {
    
    func configure(cell: AnswerWithTextTableViewCell, answer: Answer, delegate: AnswerTableViewCellDelegate, selected: Bool) -> UITableViewCell {
        cell.delegate = delegate
        cell.button.setTitle(answer.text, for: .normal)
        cell.button.setTitleColor(UIColor.black, for: .normal)
        cell.button.layer.defaultCornerRadius(borderColor: MVColors.grey.color.cgColor)
        cell.button.layer.dropDefaultShadow()
        cell.answer = answer

        if selected {
            cell.button.backgroundColor = MVColors.yellow.color
            cell.textViewHeight.constant = 150
        } else {
            cell.button.backgroundColor = UIColor.white
            cell.textViewHeight.constant = 0
        }
        
        return cell
    }
}
