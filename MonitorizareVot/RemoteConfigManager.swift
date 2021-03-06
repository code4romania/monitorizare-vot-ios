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
    case checkAppUpdateAvailable = "ios_check_update_available"
    case forceAppUpdate = "ios_force_update"
    case privacyPolicyUrl = "privacy_policy_url"
    case callCenterPhone = "call_center_phone"
    case observerGuideUrl = "observer_guide_url"
    case safetyGuideUrl = "safety_guide_url"
    case observerFeedbackUrl = "observer_feedback_url"
    case contactEmail = "contact_email"
    case roundStartTime = "round_start_time"

    func defaultValue() -> Any {
        switch self {
        case .filterDiasporaForms: return true
        case .checkAppUpdateAvailable: return true
        case .forceAppUpdate: return true
        case .privacyPolicyUrl: return "https://code4.ro/ro/codul-de-conduita/"
        case .callCenterPhone: return "0800080200"
        case .observerGuideUrl: return "https://fiecarevot.ro/wp-content/uploads/2019/11/Manual-prezidentiale.pdf"
        case .safetyGuideUrl: return ""
        case .observerFeedbackUrl: return ""
        case .contactEmail: return "contact@code4.ro"
        case .roundStartTime: return ""
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
    
    fileprivate var blocksToRunOnLoad: [() -> Void] = []
    
    private(set) var isLoaded: Bool = false
    private(set) var isLoading: Bool = false

    override init() {
        super.init()
        let defaults = RemoteConfigKey.defaultValues()
        config.setDefaults(defaults as? [String: NSObject])
        fetchRemoteConfig()
    }
    
    private func fetchRemoteConfig() {
        self.isLoading = true
        config.fetch(withExpirationDuration: TimeInterval(10)) { [weak self] (status, error) -> Void in
            guard let self = self else { return }
            self.isLoading = false
            if status == .success {
                DebugLog("RemoteConfig loaded.")
                self.config.activate { [weak self] (success, error) in
                    DebugLog("RemoteConfig activated.")
                    self?.isLoaded = true
                    self?.runWaitingBlocks()
                }
            } else {
                DebugLog("RemoteConfig not loaded. " + (error?.localizedDescription ?? "") + ". Sticking with local config")
                self.isLoaded = false
            }
        }

    }
    
    func value(of key: RemoteConfigKey) -> RemoteConfigValue {
        return config.value(of: key)
    }
    
    /// Runs the waiting blocks and clears the list
    private func runWaitingBlocks() {
        DispatchQueue.main.async {
            for block in self.blocksToRunOnLoad {
                block()
            }
            self.blocksToRunOnLoad.removeAll()
        }
    }
    
    /// Make sure this block is run after remote config has been loaded
    func afterLoad(_ block: @escaping () -> Void) {
        guard !isLoaded else { block(); return }
        DispatchQueue.main.async {
            self.blocksToRunOnLoad.append(block)
            
            if !self.isLoading {
                self.fetchRemoteConfig()
            }
        }
    }
}
