//
//  AppLanguageManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 20/09/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class AppLanguageManager: NSObject {
    static let shared = AppLanguageManager()
    
    private(set) var supportedLanguages: [String] = ["en"]
    
    var selectedLanguage: String? {
        didSet {
            save()
        }
    }

    private override init() {
        super.init()
        load()
    }
    
    private func load() {
        if let languagesInline = Bundle.main.infoDictionary?["ALLOWED_LANGUAGES"] as? String {
            supportedLanguages = languagesInline.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        } else {
            supportedLanguages = ["en"] // default to english
        }	
        
        if let savedLanguage = PreferencesManager.shared.languageLocale {
            selectedLanguage = savedLanguage
        } else {
            // select the current system language if it's in the list
            let systemLanguage = Locale.current.identifier
            if supportedLanguages.contains(systemLanguage) {
                selectedLanguage = systemLanguage
                // also save it for later
                save()
            }
        }
        
    }
    
    func languageName(forIdentifier identifier: String) -> String {
        return Locale(identifier: identifier)
            .localizedString(forLanguageCode: identifier)?.capitalized ?? identifier.capitalized
    }
    
    func save() {
        guard let selectedLanguage = selectedLanguage else { return }
        PreferencesManager.shared.languageLocale = selectedLanguage
        PreferencesManager.shared.languageName = languageName(forIdentifier: selectedLanguage)
    }
    
}
