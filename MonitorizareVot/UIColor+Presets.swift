//  Created by Code4Romania

import UIKit

extension UIColor {
    
    static var colorSchema: ColorSchema.Type {
        // UserInterfaceStyle is available from iOS 12, but dark mode is only available from iOS 13.
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .light ?
                StandardColorSchema.self :
                DarkModeColorSchema.self
        } else {
            return StandardColorSchema.self
        }
    }
    
    convenience init(hexCode: UInt32) {
        var alpha = hexCode >> 24 & 0xFF
        let red   = hexCode >> 16 & 0xFF
        let green = hexCode >> 8 & 0xFF
        let blue  = hexCode >> 0 & 0xFF
        if alpha == 0 {
            alpha = 0xFF
        }
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha:CGFloat(alpha) / 255.0)
    }
    
}
