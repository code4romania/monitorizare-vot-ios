//  Created by Code4Romania

import Foundation

class LocalFormsPersistor: FormsPersistor {
    
    func save(version: Int, name: String, informations: [[String : AnyObject]]) {
        UserDefaults.standard.set(version, forKey: name + "version")
        let data = NSKeyedArchiver.archivedData(withRootObject: informations)
        UserDefaults.standard.set(data, forKey: name + "informations")
    }

    func getVersion(forForm: String) -> Int {
        if let version = UserDefaults.standard.value(forKey: forForm + "version") as? Int {
            return version
        }
        return 0
    }

    func getInformations(forForm: String) -> [[String :AnyObject]]? {
        if let data = UserDefaults.standard.value(forKey: forForm + "informations") as? Data {
            if let informations = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String: AnyObject]] {
                return informations
            }
        }
        return nil
    }
    
}
