//
//  PresidingOfficer.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/15/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation

class PresidingOfficer {
    var judet: String?
    var sectie: String?
    var medium: String?
    var genre: String?
    var arriveHour: String = "00"
    var arriveMinute: String = "00"
    var leftHour: String = "00"
    var leftMinute: String = "00"
    
    func resetSectionInformations() {
        medium = nil
        genre = nil
        arriveHour = "00"
        arriveMinute = "00"
        leftHour = "00"
        leftMinute = "00"
    }
}
