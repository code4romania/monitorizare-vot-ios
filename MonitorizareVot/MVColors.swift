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
    case Yellow
    
    var color: UIColor {
        get {
            switch self {
            case .Yellow:
                return UIColor(colorLiteralRed: 255.0/255.0, green: 204.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            }
        }
    }
}
