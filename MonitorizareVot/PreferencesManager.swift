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
    var section: String? { get set }
}

class PreferencesManager: NSObject, PreferencesManagerType {
    static let shared: PreferencesManagerType = PreferencesManager()
    
    enum SettingKey {
       static let county = "county"
       static let section = "section"
    }
    
    var county: String? {
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: SettingKey.county)
            } else {
                UserDefaults.standard.removeObject(forKey: SettingKey.county)
            }
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.string(forKey: SettingKey.county)
        }
    }

    var section: String? {
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: SettingKey.section)
            } else {
                UserDefaults.standard.removeObject(forKey: SettingKey.section)
            }
            UserDefaults.standard.synchronize()
        } get {
            return UserDefaults.standard.string(forKey: SettingKey.section)
        }
    }
}
