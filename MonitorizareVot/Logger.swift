//  Created by Code4Romania

import Foundation
import Firebase

struct Logger {
    static func logAuthenticationWithSuccess(success: Bool, response: Any?) -> Void {
        if (success) {
            Analytics.logEvent(AnalyticsEventLogin, parameters: nil)
        } else {
            Analytics.logEvent("login_failed", parameters: response != nil ? ["response": response!] : nil)
        }
    }
}
