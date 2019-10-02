//
//  SectionHUDViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class SectionHUDViewModel: NSObject {
    var sectionName: String
    
    init(withSectionName sectionName: String) {
        self.sectionName = sectionName
        super.init()
    }
}
