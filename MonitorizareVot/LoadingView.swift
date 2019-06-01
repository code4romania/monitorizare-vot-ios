//
//  LoadingView.swift
//  MonitorizareVot
//
//  Created by Andrei Stanescu on 6/1/19.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SnapKit

class LoadingView: UIView {

    override init(frame: CGRect) {
        super.init(frame:frame)
        build()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    
    private func build() {
        self.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        
        let indicatorView = UIActivityIndicatorView(style: .whiteLarge)
        indicatorView.startAnimating()
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { (make: ConstraintMaker) in
            make.center.equalToSuperview()
        }
    }
}
