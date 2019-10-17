//
//  LocalPollingStationsPersistor.swift
//  MonitorizareVot
//
//  Created by Andrei Stanescu on 6/1/19.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation

protocol PollingStationsPersistor {
    func savePollingStations(_ pollingStations: [PollingStation])
    func getPollingStations() -> [PollingStation]?
}

class LocalPollingStationsPersistor: PollingStationsPersistor {
    
    fileprivate enum UserDefaultsKeys: String {
        case pollingStations = "storedPollingStations"
    }
    
    // MARK: - PollingStationsPersistor
    
    func savePollingStations(_ pollingStations: [PollingStation]) {
        let data = try! JSONEncoder().encode([pollingStations])
        UserDefaults.standard.set(data, forKey: UserDefaultsKeys.pollingStations.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func getPollingStations() -> [PollingStation]? {
        guard let data = UserDefaults.standard.value(forKey: UserDefaultsKeys.pollingStations.rawValue) as? Data else {
            return nil
        }
        return try! JSONDecoder().decode([PollingStation].self, from: data)
        //return NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String: AnyObject]]
    }
}
