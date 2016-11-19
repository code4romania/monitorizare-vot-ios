//
//  NoteSaver.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/18/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import Alamofire

struct NoteSaver {
    func save(note: Note) {
        connectionState { (connected) in
            if connected {
                
            } else {
                
            }
        }
    }
}
