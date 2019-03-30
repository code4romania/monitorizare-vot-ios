//  Created by Code4Romania

import Foundation
import UIKit

extension UIButton {
    func setTitle(_ title: String?, with color: UIColor, for state: UIControl.State) {
        self.setTitle(title, for: state)
        self.setTitleColor(color, for: state)
    }
}
