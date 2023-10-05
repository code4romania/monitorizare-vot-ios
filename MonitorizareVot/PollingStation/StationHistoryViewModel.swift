//
//  StationHistoryViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/11/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import UIKit

struct VisitedStationModel {
    var name: String
    var stationId: String
    var countyCode: String
    var countyName: String
    var provinceCode: String
    var provinceName: String
    var municipalityCode: String
    var municipalityName: String
}

class StationHistoryViewModel: NSObject {
    
    lazy var visitedStations: [VisitedStationModel] = {
        let sectionInfos = DB.shared.getVisitedSections()
        return sectionInfos.map {
            return VisitedStationModel(
                name: $0.sectionFullName ?? "",
                stationId: "\($0.sectionId)",
                countyCode: $0.countyCode ?? "",
                countyName: $0.countyName ?? "",
                provinceCode: $0.provinceCode ?? "",
                provinceName: $0.provinceName ?? "",
                municipalityCode: $0.municipalityCode ?? "",
                municipalityName: $0.municipalityName ?? "")
        }
    }()
}
