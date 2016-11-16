//
//  FormsPersistor.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/16/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

protocol FormsPersistor {
    func save(version: Int, name: String, data: [[String :AnyObject]])
    
    func getVersion(forForm: String) -> Int
    func getInformations(forForm: String) -> [[String :AnyObject]]?
}
