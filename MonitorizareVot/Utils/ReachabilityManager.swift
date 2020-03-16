//
//  ReachabilityManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 22/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit
import Reachability

class ReachabilityManager: NSObject {
    static let shared = ReachabilityManager()
    
    private var reachability: Reachability?
    
    fileprivate(set) var isReachable: Bool = false
    
    deinit {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        initializeReachability()
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func initializeReachability() {
        let reachability = try? Reachability()
        reachability?.whenReachable = { r in
            self.isReachable = true
        }
        reachability?.whenUnreachable = { r in
            MVAnalytics.shared.log(event: .internetDown)
            self.isReachable = false
        }
        do {
            try reachability?.startNotifier()
        } catch {
            DebugLog("Can't start reachability notifier")
        }
        self.reachability = reachability
    }
    
    @objc fileprivate func handleAppForeground(_ notification: Notification) {
        try? reachability?.startNotifier()
    }
    
    @objc fileprivate func handleAppBackground(_ notification: Notification) {
        reachability?.stopNotifier()
    }
    
}
