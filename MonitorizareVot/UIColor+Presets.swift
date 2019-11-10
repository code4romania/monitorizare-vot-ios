//  Created by Code4Romania

import Foundation
import UIKit

extension UIColor {
    
    static let navigationBarBackground = UIColor(hexCode: 0xFFCC00)
    static let navigationBarTint = UIColor(hexCode: 0x333E48)
    
    // Important: We need to make these checks until we have the minimum deployment set to iOS 11

    static var appBackground = UIColor(hexCode: 0xFAFAFA)
    static var headerBackground = UIColor(hexCode: 0xFFFFFF)
    static var defaultText = UIColor(hexCode: 0x333E48)

    static var formNameText = UIColor.black

    static var chooserButtonBorder = UIColor(hexCode: 0x333E48).withAlphaComponent(0.3)
    static var chooserButtonBackground = UIColor.clear
    static var chooserButtonSelectedBackground = navigationBarBackground

    static var actionButtonForeground = UIColor(hexCode: 0x81175C)
    static var actionButtonForegroundDisabled = actionButtonForeground.withAlphaComponent(0.4)
    static var actionButtonBackground = actionButtonForeground.withAlphaComponent(0.065)
    static var actionButtonBackgroundHighlighted = actionButtonForeground.withAlphaComponent(0.14)
    static var actionButtonBackgroundDisabled = actionButtonForeground.withAlphaComponent(0.026)

    static var attachButtonForeground = actionButtonForeground
    static var attachButtonForegroundDisabled = attachButtonForeground.withAlphaComponent(0.4)
    static var attachButtonBackground = UIColor.clear
    static var attachButtonBackgroundHighlighted = attachButtonForeground.withAlphaComponent(0.07)

    static var cardBackground = UIColor.white
    static var cardBackgroundSelected = chooserButtonSelectedBackground
    static var cardShadow = UIColor.black.withAlphaComponent(0.03)
    static var cardDarkerShadow = UIColor.black.withAlphaComponent(0.12)
    static var tableSectionHeaderBg = UIColor(hexCode: 0xEEEDED)

    static var textViewContainerBorder = UIColor(hexCode: 0xDDDDDD)
    static var textViewContainerBg = UIColor(hexCode: 0xFCFCFC)

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
