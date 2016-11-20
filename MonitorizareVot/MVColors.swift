//
//  MVColors.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/15/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

enum MVColors {
    case yellow
    case grey
    case green
    var color: UIColor {
        get {
            switch self {
            case .yellow:
                return UIColor(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            case .grey:
                return UIColor(colorLiteralRed: 172.0/255.0, green: 180.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            case .green:
                return UIColor(colorLiteralRed: 29.0/255.0, green: 191.0/255.0, blue: 48.0/255.0, alpha: 1.0)
            }
        }
    }
}
