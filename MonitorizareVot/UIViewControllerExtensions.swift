//  Created by Code4Romania

import Foundation
import UIKit

extension UIViewController {
    func performKeyboardAnimation() {
        UIView.animate(withDuration: 0.35, animations: {
            self.view.layoutIfNeeded()
        })
    }
}
