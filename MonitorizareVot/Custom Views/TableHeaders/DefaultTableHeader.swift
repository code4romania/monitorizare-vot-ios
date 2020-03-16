//
//  DefaultTableHeader.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 26/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class DefaultTableHeader: UIView {
    
    var titleLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let width = frame.width
        backgroundColor = .clear
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: frame.height - 10))
        container.backgroundColor = .tableSectionHeaderBg
        addSubview(container)
        
        titleLabel = UILabel(frame: container.bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)))
        container.addSubview(titleLabel)

        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.textColor = UIColor.defaultText.withAlphaComponent(0.3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
