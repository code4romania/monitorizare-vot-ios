//
//  AccountManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 17/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper


protocol AccountManagerType: NSObject {
    /// Returns the device unique ID (generates one if not determined yet)
    var udid: String { get }
    
    /// The logged in user's access token. Nil means unauthenticated
    var accessToken: String? { get set }
}


class AccountManager: NSObject, AccountManagerType {
    
    enum SettingKey {
        static let udid = "udid"
        static let token = "token"
    }
    
    static let shared: AccountManagerType = AccountManager()
    
    var udid: String {
        if let savedUdid = KeychainWrapper.standard.string(forKey: SettingKey.udid) {
            return savedUdid
        } else {
            let udid = NSUUID().uuidString
            KeychainWrapper.standard.set(udid, forKey: SettingKey.udid)
            return udid
        }
    }
    
    var accessToken: String? {
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: SettingKey.token)
            } else {
                KeychainWrapper.standard.remove(key: SettingKey.token)
            }
        } get {
            return KeychainWrapper.standard.string(forKey: SettingKey.token)
        }
    }
}
