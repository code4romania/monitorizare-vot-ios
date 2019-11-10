//
//  ChooserButton.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

@IBDesignable
class ChooserButton: UIButton {
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    fileprivate func setup() {
        setBackgroundImage(UIImage.from(color: .chooserButtonBackground), for: .normal)
        setBackgroundImage(UIImage.from(color: .chooserButtonSelectedBackground), for: .selected)
        setBackgroundImage(UIImage.from(color: UIColor.chooserButtonSelectedBackground.withAlphaComponent(0.5)), for: .highlighted)
        setBackgroundImage(UIImage.from(color: .chooserButtonSelectedBackground), for: [.selected, .highlighted])
        
        setTitleColor(.defaultText, for: .normal)
        setTitleColor(.defaultText, for: .selected)
        setTitleColor(.defaultText, for: .highlighted)
        setTitleColor(.defaultText, for: [.highlighted, .selected])
        
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        titleLabel?.minimumScaleFactor = 0.5
        titleLabel?.adjustsFontSizeToFitWidth = true
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

        tintColor = .clear

        layer.masksToBounds = true
        layer.cornerRadius = Configuration.buttonCornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.chooserButtonBorder.cgColor
        
        titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    }
    
}
