//
//  DropdownButton.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

@IBDesignable
class DropdownButton: UIButton {
    
    @IBInspectable
    var placeholder: String? {
        didSet {
            update()
        }
    }
    
    @IBInspectable
    var value: String? {
        didSet {
            update()
        }
    }
    
    fileprivate lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .defaultText
        return label
    }()
    
    fileprivate lazy var accessoryImageView: UIImageView = {
        return UIImageView(image: UIImage(named: "icon-dropdown-arrow"))
    }()

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    fileprivate func update() {
        if let value = value,
            value.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            label.textColor = .defaultText
            label.text = value
        } else {
            label.textColor = UIColor.defaultText.withAlphaComponent(0.5)
            label.text = placeholder
        }
    }
    
    fileprivate func setup() {
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(accessoryImageView)
        
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: 16).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        accessoryImageView.setContentHuggingPriority(.required, for: .horizontal)
        accessoryImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        accessoryImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        accessoryImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true

        tintColor = .clear
        
        layer.masksToBounds = true
        layer.cornerRadius = Configuration.buttonCornerRadius
        layer.borderWidth = 1
        layer.borderColor = UIColor.textViewContainerBorder.cgColor
    }


}
