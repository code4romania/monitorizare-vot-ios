//
//  OnboardingLanguageViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 04/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class OnboardingLanguageViewModel: NSObject {
    var supportedLanguages: [String]
    
    var selectedLanguage: String?
    
    var selectedLanguageIndex: Int? {
        guard let selectedLanguage = selectedLanguage else { return nil }
        return supportedLanguages.firstIndex(of: selectedLanguage)
    }
    
    override init() {
        if let languagesInline = Bundle.main.infoDictionary?["ALLOWED_LANGUAGES"] as? String {
            supportedLanguages = languagesInline.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        } else {
            supportedLanguages = ["en"] // default to english
        }
        
        // also select the current language if it's in the list
        let systemLanguage = Locale.current.identifier
        if supportedLanguages.contains(systemLanguage) {
            selectedLanguage = systemLanguage
        }
        
        super.init()
    }
    
    func languageName(forIdentifier identifier: String) -> String {
        return Locale(identifier: identifier).localizedString(forLanguageCode: identifier)?.capitalized ?? identifier.capitalized
    }
    
    func save(then callback: () -> Void) {
        guard let selectedLanguage = selectedLanguage else { return }
        PreferencesManager.shared.languageLocale = selectedLanguage
        PreferencesManager.shared.languageName = languageName(forIdentifier: selectedLanguage)
        callback()
    }
    
}
