//
//  MigrationManager.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 16/11/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import Foundation

class MigrationManager: NSObject {
    static let shared = MigrationManager()
    
    private override init() {
        super.init()
    }
    
    func migrateIfNecessary() {
        let lastReset = PreferencesManager.shared.lastDatabaseResetTimestamp
        let specifiedReset = RemoteConfigManager.shared.value(of: .roundStartTime).numberValue as? TimeInterval
        if let specified = specifiedReset,
           specified > 0 && specified < Date().timeIntervalSince1970 {
            // there is a specified reset time and it's overdue
            // we should reset if we never reset or there's an older reset than the specified one
            var shouldReset = lastReset == nil
            if let last = lastReset,
               last < specified  {
                shouldReset = true
            }
            
            let lastReset = lastReset != nil ? Date(timeIntervalSince1970: lastReset!) : nil
            if shouldReset {
                let specifiedDate = Date(timeIntervalSince1970: specified)
                DebugLog("Clearing existing database. The round started on \(specifiedDate), last reset happened on \(lastReset?.description ?? "--").")
                CoreData.clearDatabase()
                PreferencesManager.shared.lastDatabaseResetTimestamp = Date().timeIntervalSince1970
            } else {
                DebugLog("No database reset necessary. Last reset happened on \(lastReset?.description ?? "--")")
            }
        } else {
            if let nextReset = specifiedReset,
               nextReset > 0 {
                DebugLog("No database reset necessary. Next reset scheduled on \(Date(timeIntervalSince1970: nextReset))")
            } else {
                DebugLog("No database reset scheduled.")
            }
        }
    }
}
