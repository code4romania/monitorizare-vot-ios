//
//  APIURLs.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/15/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

enum APIURLs {
    case Login
    
    var url: NSURL {
        get {
            switch self {
            case .Login:
                return NSURL(string: "")!
            }
        }
    }
}
