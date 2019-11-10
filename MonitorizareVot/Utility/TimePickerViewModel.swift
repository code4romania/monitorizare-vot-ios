//
//  DateTimePickerViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class TimePickerViewModel: NSObject {
    var date: Date
    var dateFormatter: DateFormatter
    var minDate: Date?
    var maxDate: Date?
    
    init(withTime time: Date?, dateFormatter: DateFormatter) {
        self.date = time ?? Date()
        self.dateFormatter = dateFormatter
        super.init()
    }
    
}
