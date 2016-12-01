//
//  BasicAnswerTableViewCell.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/19/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import UIKit

class BasicAnswerTableViewCell: UITableViewCell, AnswerTableViewCell {
    
    @IBOutlet weak var button: UIButton!
    var answer: MVAnswer?
    weak var delegate: AnswerTableViewCellDelegate?
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.didTapOnButton(answer: self.answer!)
    }
}
