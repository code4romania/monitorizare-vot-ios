//
//  SectionPickerViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/11/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

enum SectionPickerViewModelError: Error {
    case genericError(reason: String)
    
    var localizedDescription: String {
        switch self {
        case .genericError(let reason): return reason
        }
    }
}

class SectionPickerViewModel: NSObject {
    
    var countyCode: String? {
        didSet {
            sectionId = nil
            onStateChanged?()
        }
    }
    
    var sectionId: Int? {
        didSet {
            onStateChanged?()
        }
    }
    
    var canContinue: Bool {
        return countyCode != nil && sectionId != nil
    }
    
    var isSectionNumberCorrect: Bool {
        return sectionId != nil && maximumStationNumber != nil && sectionId! <= maximumStationNumber!
    }
    
    var selectedCountyName: String? {
        guard let code = countyCode else { return nil }
        return getCounty(byCountyCode: code)?.name.capitalized
    }
    
    /// Be notified when the API download state has changed
    var onDownloadStateChanged: (() -> Void)?
    
    /// Be notified when the API save state has changed
    var onSaveStateChanged: (() -> Void)?
    
    /// Be notified whenever the model data changes so you can update the interface with fresh data
    var onStateChanged: (() -> Void)?
    
    fileprivate(set) var availableCounties: [CountyResponse] = []
    
    var maximumStationNumber: Int? {
        guard let selectedCounty = countyCode else { return nil }
        return getCounty(byCountyCode: selectedCounty)?.numberOfPollingStations
    }
    
    fileprivate(set) var isDownloading: Bool = false {
        didSet {
            onDownloadStateChanged?()
        }
    }
    
    fileprivate(set) var isSaving: Bool = false {
        didSet {
            onSaveStateChanged?()
        }
    }
    
    override init() {
        if let currentSection = DB.shared.currentSectionInfo() {
            countyCode = currentSection.countyCode
            sectionId = Int(currentSection.sectionId)
        }
        super.init()
    }
    
    func fetchPollingStations(then callback: @escaping (APIError?) -> Void) {
        isDownloading = true
        APIManager.shared.fetchCounties { (counties, error) in
            if let counties = counties {
                self.availableCounties = self.sorted(counties: counties)
                LocalStorage.shared.counties = counties
            }
            callback(error)
            self.isDownloading = false
        }
    }
    
    private func sorted(counties: [CountyResponse]) -> [CountyResponse] {
        counties.sorted {
            if $0.diaspora != $1.diaspora {
                // diaspora comes first
                return $0.diaspora == true && $1.diaspora != true
            } else if $0.order != $1.order {
                // account for the order field
                return $0.order < $1.order
            } else {
                // fallback to alphabetically
                return $0.name < $1.name
            }
        }
    }
    
    func availableSectionIds(inCounty county: String) -> [Int] {
        if let countyData = getCounty(byCountyCode: county) {
            return Array(1...countyData.numberOfPollingStations)
        }
        return []
    }
    
    fileprivate func getCounty(byCountyCode code: String) -> CountyResponse? {
        return availableCounties.filter { $0.code == code }.first
    }
    
    func persist(then callback: @escaping (SectionPickerViewModelError?) -> Void) {
        guard let county = countyCode,
            let sectionId = sectionId else {
            callback(.genericError(reason: "Invalid section data provided"))
            return
        }
        let _ = DB.shared.sectionInfo(for: county, sectionId: sectionId)
        PreferencesManager.shared.county = county
        PreferencesManager.shared.section = sectionId
        if let countyName = selectedCountyName {
            PreferencesManager.shared.sectionName = "Station".localized + " \(sectionId) \(countyName)"
        }
        callback(nil)
    }
    
}
