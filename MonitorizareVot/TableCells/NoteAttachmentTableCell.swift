//
//  NoteAttachmentTableCell.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/12/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class NoteAttachmentTableCell: UITableViewCell {
    static let reuseIdentifier = "NoteAttachmentTableCell"
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    
    var onDelete: (() -> Void)?
    
    @IBAction private func handleDeleteAction(_ sender: Any) {
        onDelete?()
    }
}
