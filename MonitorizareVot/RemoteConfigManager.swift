//
//  RemoteConfigManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 06/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseRemoteConfig

enum RemoteConfigKey: String, CaseIterable {
    case filterDiasporaForms = "filter_diaspora_forms"

    func defaultValue() -> Any {
        switch self {
        case .filterDiasporaForms: return true
        }
    }
}

extension RemoteConfigKey {
    public static func defaultValues() -> [String: Any] {
        var dict = [String: Any]()
        for key in allCases { dict[key.rawValue] = key.defaultValue() }
        return dict
    }
}

extension RemoteConfig {
    func value(of key: RemoteConfigKey) -> RemoteConfigValue {
        return self[key.rawValue]
    }
}

class RemoteConfigManager: NSObject {
    static let shared = RemoteConfigManager()
    
    fileprivate let config = RemoteConfig.remoteConfig()
    
    override init() {
        super.init()
        let defaults = RemoteConfigKey.defaultValues()
        config.setDefaults(defaults as? [String: NSObject])
        config.fetch(withExpirationDuration: TimeInterval(10)) { [weak self] (status, error) -> Void in
            guard let self = self else { return }
            if status == .success {
                DebugLog("RemoteConfig loaded.")
                self.config.activateFetched()
            } else {
                DebugLog("RemoteConfig not loaded. " + (error?.localizedDescription ?? "") + ". Sticking with local config")
                // TODO: implement retry when reachability is back on
            }
        }
    }
    
    func value(of key: RemoteConfigKey) -> RemoteConfigValue {
        return config.value(of: key)
    }
}
