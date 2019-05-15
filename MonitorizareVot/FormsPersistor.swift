//  Created by Code4Romania

import Foundation

protocol FormsPersistor {
    func save(version: Int, id: String, description: String, informations: [[String : AnyObject]])
    
    func getForm(withId id: String) -> [String: Any]?
    func getVersion(forForm: String) -> Int
    func getInformations(forForm: String) -> [[String: AnyObject]]?
}
