//
//  StationHistoryViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/11/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

class StationHistoryViewModel: NSObject {
    
    struct StationRowModel {
        var name: String
        var stationId: String
        var stationCountyCode: String
    }
    
    lazy var visitedStations: [StationRowModel] = {
        let sectionInfos = DB.shared.getVisitedSections()
        return sectionInfos.map {
            return StationRowModel(name: $0.sectionFullName ?? "",
                            stationId: "\($0.sectionId)",
                            stationCountyCode: $0.countyCode ?? "")
        }
    }()
}
