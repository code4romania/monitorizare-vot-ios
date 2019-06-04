//  Created by Code4Romania

import Foundation
import UIKit

enum MVColors {
    case yellow
    case gray
    case green
    case lightGray
    case black
    case white
    case clear
    
    var color: UIColor {
        get {
            switch self {
            case .yellow:
                return UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.0)
            case .gray:
                return UIColor(red:0.67, green:0.71, blue:0.75, alpha:1.0)
            case .green:
                return UIColor(red:0.11, green:0.75, blue:0.19, alpha:1.0)
            case .lightGray:
                return UIColor.lightGray
            case .black:
                return UIColor.black
            case .white:
                return UIColor.white
            case .clear:
                return UIColor.clear
            }
        }
    }
    
    var cgColor: CGColor {
        return self.color.cgColor
    }
}
