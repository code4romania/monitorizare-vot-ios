//
//  FormPickerCollectionViewCell.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 30/03/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class FormPickerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FormCell"
    
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var addIcon: UIImageView!
    
    var isAddNote: Bool = false {
        didSet {
            updateInterface()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = false
        contentView.clipsToBounds = false
        contentView.layer.dropDefaultShadow()
        contentView.layer.defaultCornerRadius(borderColor: MVColors.gray.cgColor)

    }
    
    fileprivate func updateInterface() {
        addIcon.isHidden = !isAddNote
        idLabel.isHidden = isAddNote
        if isAddNote {
            descriptionLabel.text = "Label_AddNote".localized
        }
    }

}
