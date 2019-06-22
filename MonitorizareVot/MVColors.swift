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
                return UIColor(red: 1, green: 205/255.0, blue: 0, alpha: 1)
            case .gray:
                return UIColor(red: 172/255.0, green: 180/255.0, blue: 190/255.0, alpha: 1)
            case .green:
                return UIColor(red: 29/255.0, green: 191/255.0, blue: 48/255.0, alpha: 1)
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
