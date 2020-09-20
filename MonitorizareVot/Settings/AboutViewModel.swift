//
//  AboutViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 20/09/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class AboutViewModel: NSObject {
    var versionText: String {
        guard let info = Bundle.main.infoDictionary else { return "" }
        let version = info["CFBundleShortVersionString"] ?? "1.0"
        let build = info["CFBundleVersion"] ?? "1"
        var versionString = "v\(version)"
        #if DEBUG
        versionString += "(\(build))"
        #endif
        return versionString
    }
    
    var contactEmailUrl: URL? {
        guard let email = RemoteConfigManager.shared.value(of: .contactEmail).stringValue else {
            assertionFailure("No contact email set up in RemoteConfig")
            return nil
        }

        let mailtoPath = "mailto:\(email)"
        return URL(string: mailtoPath)
    }
    
    var privacyPolicyUrl: URL? {
        guard let urlStr = RemoteConfigManager.shared.value(of: .privacyPolicyUrl).stringValue,
              let url = URL(string: urlStr) else {
            assertionFailure("No policy url set up in RemoteConfig")
            return nil
        }

        return url
    }
    
    var languageOptions: [GenericPickerValue] {
        let manager = AppLanguageManager.shared
        let languages = manager.supportedLanguages
        let possibleValues = languages.map { GenericPickerValue(id: $0, displayName: manager.languageName(forIdentifier: $0)) }
        return possibleValues
    }
    
    var selectedLanguageIndex: Int {
        let manager = AppLanguageManager.shared
        guard let selectedLanguage = manager.selectedLanguage else { return 0 }
        let languages = manager.supportedLanguages
        return languages.firstIndex(of: selectedLanguage) ?? 0
    }
    
    lazy var selectedLanguage: String? = {
        AppLanguageManager.shared.selectedLanguage
    }()
    
    func saveLanguage() {
        AppLanguageManager.shared.selectedLanguage = selectedLanguage
        AppLanguageManager.shared.save()
    }
    
}
