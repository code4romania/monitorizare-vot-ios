//
//  OnboardingLanguageViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 04/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class OnboardingLanguageViewModel: NSObject {
    var supportedLanguages: [String] {
        get { AppLanguageManager.shared.supportedLanguages }
    }
    
    var selectedLanguage: String?
    
    var selectedLanguageIndex: Int? {
        guard let selectedLanguage = selectedLanguage else { return nil }
        return supportedLanguages.firstIndex(of: selectedLanguage)
    }
    
    override init() {
        self.selectedLanguage = AppLanguageManager.shared.selectedLanguage
        super.init()
    }
    
    func languageName(forIdentifier identifier: String) -> String {
        AppLanguageManager.shared.languageName(forIdentifier: identifier)
    }
    
    func save() {
        guard let selectedLanguage = selectedLanguage else { return }
        AppLanguageManager.shared.selectedLanguage = selectedLanguage
        AppLanguageManager.shared.save()
    }
    
}
