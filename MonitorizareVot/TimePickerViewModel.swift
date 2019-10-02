//
//  DateTimePickerViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class TimePickerViewModel: NSObject {
    var date: Date?
    
    var timeString: String? {
        if let date = date {
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            return String(format: "%02d:%02d", hour, minute)
        } else {
            return nil
        }
    }
    
    init(withTimeString time: String) {
        date = TimePickerViewModel.timeStringToDate(time)
        super.init()
    }
    
    static func timeStringToDate(_ timeString: String) -> Date? {
        let components = timeString.components(separatedBy: ":")
        if components.count == 2 {
            let hour = Int(components[0])
            let minute = Int(components[1])
            var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
            dateComponents.hour = hour
            dateComponents.minute = minute
            return Calendar.current.date(from: dateComponents)
        }
        return nil
    }
}
