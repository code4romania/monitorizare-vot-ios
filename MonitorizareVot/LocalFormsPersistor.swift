//
//  LocalFormsPersistor.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/16/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

class LocalFormsPersistor: FormsPersistor {
    
    func save(version: Int, name: String, data: [[String : AnyObject]]) {
        UserDefaults.standard.set(version, forKey: name + "version")
        UserDefaults.standard.set(data, forKey: name + "informations")
    }

    func getVersion(forForm: String) -> Int {
        if let version = UserDefaults.standard.value(forKey: forForm + "version") as? Int {
            return version
        }
        return 0
    }

    func getInformations(forForm: String) -> [[String :AnyObject]]? {
        if let informations = UserDefaults.standard.value(forKey: forForm + "informations") as? [[String :AnyObject]]  {
            return informations
        }
        return nil
    }
    
}
