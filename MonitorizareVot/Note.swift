//
//  Note.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/18/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

class Note {
    var presidingOfficer: PresidingOfficer
    var questionID: String?
    var body: String?
    var image: UIImage?
    var synced: Bool = false
    
    init(presidingOfficer: PresidingOfficer) {
        self.presidingOfficer = presidingOfficer
    }
}
