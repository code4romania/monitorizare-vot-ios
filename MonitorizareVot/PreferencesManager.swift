//
//  PreferencesManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit


protocol PreferencesManagerType: NSObject {
    var wasOnboardingShown: Bool { get set }
    var county: String? { get set }
    var section: Int? { get set }
    var sectionName: String? { get set }
    var languageLocale: String? { get set }
    var languageName: String? { get set }
    var wasAppStartedBefore: Bool { get }
}

class PreferencesManager: NSObject, PreferencesManagerType {
    static let shared: PreferencesManagerType = PreferencesManager()
    
    enum SettingKey: String {
        case wasOnboardingShown = "PreferenceWasOnboardingShown"
        case county = "PreferenceCounty"
        case section = "PreferenceSectionId"
        case sectionName = "PreferenceSectionName"
        case languageLocale = "PreferenceLanguageLocale"
        case languageName = "PreferenceLanguageName"
    }
    
    var county: String? {
        set {
            setValue(newValue, forKey: .county)
        } get {
            return getValue(forKey: .county) as? String
        }
    }

    var section: Int? {
        set {
            setValue(newValue, forKey: .section)
        } get {
            return getValue(forKey: .section) as? Int
        }
    }
    
    var sectionName: String? {
        set {
            setValue(newValue, forKey: .sectionName)
        } get {
            return getValue(forKey: .sectionName) as? String
        }
    }
    
    var wasOnboardingShown: Bool {
        set {
            setValue(newValue, forKey: .wasOnboardingShown)
        } get {
            return getValue(forKey: .wasOnboardingShown) as? Bool ?? false
        }
    }
    
    var languageLocale: String? {
        set {
            setValue(newValue, forKey: .languageLocale)
        } get {
            return getValue(forKey: .languageLocale) as? String
        }
    }
    
    var languageName: String? {
        set {
            setValue(newValue, forKey: .languageName)
        } get {
            return getValue(forKey: .languageName) as? String
        }
    }
    
    var wasAppStartedBefore: Bool { return wasOnboardingShown }
    
    // MARK: - Helpers
    
    fileprivate func setValue(_ value: Any?, forKey key: SettingKey) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: key.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        UserDefaults.standard.synchronize()
    }

    fileprivate func getValue(forKey key: SettingKey) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
}
