//  Created by Code4Romania

import Foundation


class LocalFormsPersistor: FormsPersistor {

    fileprivate enum UserDefaultsKeys: String {
        @available(*, deprecated, message: "use `formList` instead")
        case forms = "forms"
        case formList = "formList"
        case formPrefix = "form:"
    }
    
    enum FormSummaryKeys {
        static let id = "id"
        static let version = "ver"
        static let description = "description"
    }
    
    // MARK: - Public
    
    /// Saves the form summary (id and version), along with the form details
    func save(version: Int, id: String, description: String, informations: [[String : AnyObject]]) {
        saveFormSummary(withId: id, version: version, description: description)
        saveFormSections(withId: id, sections: informations)
    }
    
    /// Returns the list of all forms
    func getAllForms() -> [[String: Any]] {
        let forms = getAllFormSummaries()
        return forms.sorted { ($0[FormSummaryKeys.id] as! String) < ($1[FormSummaryKeys.id] as! String) }
    }
    
    /// Fetches the version of the specified form or 0 if not found
    func getVersion(forForm id: String) -> Int {
        if let form = getForm(withId: id) {
            return form[FormSummaryKeys.version] as? Int ?? 0
        }
        return 0
    }
    
    /// Gets the full form summary object
    func getForm(withId id: String) -> [String : Any]? {
        let form = (getAllFormSummaries().filter { $0["id"] as? String == id }).first
        return form
    }

    /// Fetches the full form from storage
    func getInformations(forForm id: String) -> [[String :AnyObject]]? {
        let key = UserDefaultsKeys.formPrefix.rawValue + id
        
        guard let data = UserDefaults.standard.value(forKey: key) as? Data else { return nil }
        guard let form = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String :AnyObject]] else { return nil }
        
        return form
    }
    
    // MARK: - Internals
    
    /// Saves the form summary as a hash
    fileprivate func saveFormSummary(withId id: String, version: Int, description: String) {
        guard id.count > 0 else { return } // make sure we have a valid id
        
        let key = UserDefaultsKeys.formList.rawValue
        var forms: [[String: Any]] = []
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            if let object = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String: Any]] {
                forms = object
            }
        }
        
        var form: [String: Any] = [:]
        form[FormSummaryKeys.id] = id
        form[FormSummaryKeys.version] = version
        form[FormSummaryKeys.description] = description
        
        forms.removeAll { $0[FormSummaryKeys.id] as? String == id }
        forms.append(form)
        
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
    
    fileprivate func getAllFormSummaries() -> [[String: Any]] {
        guard let data = UserDefaults.standard.value(forKey: UserDefaultsKeys.formList.rawValue) as? Data else { return [] }
        
        guard let forms = NSKeyedUnarchiver.unarchiveObject(with: data) as? [[String: Any]] else { return [] }
        
        return forms
    }
    
}
