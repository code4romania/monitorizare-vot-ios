//
//  LocalPollingStationsPersistor.swift
//  MonitorizareVot
//
//  Created by Andrei Stanescu on 6/1/19.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation

protocol PollingStationsPersistor {
    func savePollingStations(_ pollingStations: [[String : AnyObject]])
    func getPollingStations() -> [[String : AnyObject]]?
}

class LocalPollingStationsPersistor: PollingStationsPersistor {
    
    fileprivate enum UserDefaultsKeys: String {
        case pollingStations = "pollingStations"
    }
    
    // MARK: - PollingStationsPersistor
    
    func savePollingStations(_ pollingStations: [[String : AnyObject]]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: pollingStations)
        if data.count == 0 {
            print("Error saving the polling stations locally")
            return
        }
        UserDefaults.standard.set(data, forKey: UserDefaultsKeys.pollingStations.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func getPollingStations() -> [[String : AnyObject]]? {
        guard let data = UserDefaults.standard.value(forKey: UserDefaultsKeys.pollingStations.rawValue) as? Data else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String: AnyObject]]
    }
}
