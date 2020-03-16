//  Created by Code4Romania

import Foundation

extension String {
    var localized: String {
        get {
            if var customLocale = PreferencesManager.shared.languageLocale {
                if customLocale == "en" {
                    customLocale = "Base"
                }
                if let path = Bundle.main.path(forResource: customLocale, ofType: "lproj") {
                    let bundle = Bundle(path: path)
                    return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
                }
            }
            return NSLocalizedString(self, comment: "")
        }
    }
    
    var currentLanguage: String? {
        return PreferencesManager.shared.languageLocale
    }
}
