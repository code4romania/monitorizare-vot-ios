//
//  TextContainer.swift
//  MonitorizareVot
//
//  Created by Cristian Habliuc on 29/9/23.
//  Copyright © 2023 Code4Ro. All rights reserved.
//

import UIKit

@IBDesignable
class TextContainer: UIView {
//    override func willMove(toWindow newWindow: UIWindow?) {
//        super.willMove(toWindow: newWindow)
//        setup()
//    }
//    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    fileprivate func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = UIConfiguration.buttonCornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.chooserButtonBorder.cgColor
    }
}
