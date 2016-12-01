//
//  Note.swift
//  MonitorizareVot
//
//  Created by Andrei Nastasiu on 11/18/16.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import UIKit

class MVNote {
    var presidingOfficer: MVPresidingOfficer
    var questionID: String?
    var body: String?
    var image: UIImage?
    var synced: Bool = false
    
    init(presidingOfficer: MVPresidingOfficer) {
        self.presidingOfficer = presidingOfficer
    }
}
