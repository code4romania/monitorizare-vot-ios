//
//  PreferencesManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit


protocol PreferencesManagerType: NSObject {
    var county: String? { get set }
    var section: Int? { get set }
    var sectionName: String? { get set }
}

class PreferencesManager: NSObject, PreferencesManagerType {
    static let shared: PreferencesManagerType = PreferencesManager()
    
    enum SettingKey: String {
        case county = "county"
        case section = "sectionId"
        case sectionName = "sectionName"
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
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
}
