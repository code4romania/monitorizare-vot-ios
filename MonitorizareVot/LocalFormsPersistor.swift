//  Created by Code4Romania

import Foundation


class LocalFormsPersistor: FormsPersistor {

    fileprivate enum UserDefaultsKeys: String {
        case forms = "forms"
        case formPrefix = "form:"
    }
    
    // MARK: - Public
    
    /// Saves the form summary (id and version), along with the form details
    func save(version: Int, name: String, informations: [[String : AnyObject]]) {
        saveFormSummary(withId: name, version: version)
        saveFormSections(withId: name, sections: informations)
    }
    
    /// Returns the list of all form ids
    func getAllForms() -> [String] {
        let forms = getAllFormSummaries()
        return Array(forms.keys).sorted()
    }
    
    /// Fetches the version of the specified form or 0 if not found
    func getVersion(forForm id: String) -> Int {
        let forms = getAllFormSummaries()
        return forms[id] ?? 0
    }

    /// Fetches the full form from storage
    func getInformations(forForm id: String) -> [[String :AnyObject]]? {
        let key = UserDefaultsKeys.formPrefix.rawValue + id
        
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else { return nil }
        guard let form = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String :AnyObject]] else { return nil }
        
        return form
    }
    
    // MARK: - Internals
    
    /// Saves the form summary as a hash ([id: version])
    fileprivate func saveFormSummary(withId id: String, version: Int) {
        let key = UserDefaultsKeys.forms.rawValue
        var forms: [String: Int] = [:]
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            if let object = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Int] {
                forms = object
            }
        }
        
        forms[id] = version
        
        let data = NSKeyedArchiver.archivedData(withRootObject: forms)
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func saveFormSections(withId id: String, sections: [[String: AnyObject]]) {
        let key = UserDefaultsKeys.formPrefix.rawValue + id
        
        let data = NSKeyedArchiver.archivedData(withRootObject: sections)
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    fileprivate func getAllFormSummaries() -> [String: Int] {
        guard let data = UserDefaults.standard.value(forKey: UserDefaultsKeys.forms.rawValue) as? Data else { return [:] }
        
        guard let forms = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Int] else { return [:] }
        
        return forms
    }
    
}
