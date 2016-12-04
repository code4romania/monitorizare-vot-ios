//  Created by Code4Romania

import Foundation

protocol FormsPersistor {
    func save(version: Int, name: String, informations: [[String :AnyObject]])
    
    func getVersion(forForm: String) -> Int
    func getInformations(forForm: String) -> [[String :AnyObject]]?
}
