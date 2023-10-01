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
    var province: ProvinceResponse? { get set }
    var county: CountyResponse? { get set }
    var municipality: MunicipalityResponse? { get set }
    var section: Int? { get set }
    var sectionName: String? { get set }
    var languageLocale: String? { get set }
    var languageName: String? { get set }
    var wasAppStartedBefore: Bool { get }
    /// When the database was last reset (UTC timestamp)
    var lastDatabaseResetTimestamp: TimeInterval? { get set }
}

class PreferencesManager: NSObject, PreferencesManagerType {
    static let shared: PreferencesManagerType = PreferencesManager()
    
    enum SettingKey: String {
        case wasOnboardingShown = "PreferenceWasOnboardingShown"
        case province = "PreferenceProvinceObj"
        case county = "PreferenceCountyObj"
        case municipality = "PreferenceMunicipalityObj"
        case section = "PreferenceSectionId"
        case sectionName = "PreferenceSectionName"
        case languageLocale = "PreferenceLanguageLocale"
        case languageName = "PreferenceLanguageName"
        case lastDatabaseResetTimestamp = "PreferenceLastDatabaseResetTimestamp"
    }
    
    var province: ProvinceResponse? {
        set {
            setCodable(newValue, forKey: .province)
        } get {
            return getCodable(forKey: .province)
        }
    }
    
    var county: CountyResponse? {
        set {
            setCodable(newValue, forKey: .county)
        } get {
            return getCodable(forKey: .county)
        }
    }
    
    var municipality: MunicipalityResponse? {
        set {
            setCodable(newValue, forKey: .municipality)
        } get {
            return getCodable(forKey: .municipality)
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
    
    var lastDatabaseResetTimestamp: TimeInterval? {
        set {
            setValue(newValue, forKey: .lastDatabaseResetTimestamp)
        } get {
            return getValue(forKey: .lastDatabaseResetTimestamp) as? TimeInterval
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func setValue(_ value: Any?, forKey key: SettingKey) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: key.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func setCodable(_ value: Encodable?, forKey key: SettingKey) {
        if let value = value {
            let data = try! JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key.rawValue)
        } else {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func getValue(forKey key: SettingKey) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
    
    fileprivate func getCodable<T: Decodable>(forKey key: SettingKey) -> T? {
        guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {
            return nil
        }
        return try! JSONDecoder().decode(T.self, from: data)
    }
}
