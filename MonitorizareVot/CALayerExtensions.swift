//  Created by Code4Romania

import Foundation
import UIKit

extension CALayer {
    
    func dropDefaultShadow() {
        self.cornerRadius = 4
        self.borderWidth = 1
        self.borderColor = UIColor(red: 172, green: 180, blue: 190, alpha: 1).cgColor
        self.masksToBounds = false
        self.shadowColor = MVColors.black.cgColor
        self.shadowRadius = 4.0
        self.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.shadowOpacity = 0.07
    }
    
    func defaultCornerRadius(borderColor: CGColor) {
        self.cornerRadius = 5
        self.borderColor = borderColor
        self.borderWidth = 1.0
    }
}
