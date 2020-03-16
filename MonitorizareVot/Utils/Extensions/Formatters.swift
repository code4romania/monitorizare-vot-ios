//
//  Formatters.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let sectionTime: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()

    static let noteCell: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()
}
