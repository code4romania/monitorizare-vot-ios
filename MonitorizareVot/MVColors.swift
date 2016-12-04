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
                return UIColor(colorLiteralRed: 255.0/255.0, green: 205.0/255.0, blue: 0.0/255.0, alpha: 1.0)
            case .gray:
                return UIColor(colorLiteralRed: 172.0/255.0, green: 180.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            case .green:
                return UIColor(colorLiteralRed: 29.0/255.0, green: 191.0/255.0, blue: 48.0/255.0, alpha: 1.0)
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
