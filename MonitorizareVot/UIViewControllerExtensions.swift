//
//  UIViewControllerExtensions.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/18/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func performKeyboardAnimation() {
        UIView.animate(withDuration: 0.35, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
