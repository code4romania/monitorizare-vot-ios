//
//  UIViewController+Helpers.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 03/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Traverses the modal view controllers chain and returns the topmost visible view controller
    var topmostViewController: UIViewController {
        var topmost = self
        while let presented = topmost.presentedViewController {
            if !(presented is UIAlertController) {
                topmost = presented
            }
        }
        return topmost
    }
}
