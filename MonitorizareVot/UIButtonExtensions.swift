//
//  UIButtonExtensions.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/23/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setTitle(_ title: String?, with color: UIColor, for state: UIControlState) {
        self.setTitle(title, for: state)
        self.setTitleColor(color, for: state)
    }
}
