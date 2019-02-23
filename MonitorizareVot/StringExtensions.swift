//  Created by Code4Romania

import Foundation

extension String {
    var localized: String {
        get {
            let localizedString = NSLocalizedString(self, comment: "")
            return localizedString
        }
    }
}
