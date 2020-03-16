//
//  Alerts.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func error(withMessage message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Error".localized,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
        return alert
    }
}
