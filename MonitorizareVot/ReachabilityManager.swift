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
    
    lazy private var reachability: Reachability? = {
        let reachability = try? Reachability()
        reachability?.whenReachable = { r in
            self.isReachable = true
        }
        reachability?.whenUnreachable = { r in
            self.isReachable = false
        }
        do {
            try reachability?.startNotifier()
        } catch {
            print("Can't start reachability notifier")
        }
        return reachability
    }()
    
    fileprivate(set) var isReachable: Bool = false
    
    deinit {
        reachability?.stopNotifier()
    }
    
}
