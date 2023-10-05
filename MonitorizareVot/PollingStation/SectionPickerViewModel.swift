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
    
    var selectedProvince: ProvinceResponse? {
        didSet {
            if selectedProvince != oldValue {
                selectedCounty = nil
                selectedMunicipality = nil
                sectionId = nil
            }
            onStateChanged?()
        }
    }
    var selectedCounty: CountyResponse? {
        didSet {
            if selectedCounty != oldValue {
                selectedMunicipality = nil
                sectionId = nil
            }
            onStateChanged?()
        }
    }
    var selectedMunicipality: MunicipalityResponse? {
        didSet {
            if selectedMunicipality != oldValue {
                sectionId = nil
            }
            onStateChanged?()
        }
    }
    var sectionId: Int?
    
    var canContinue: Bool {
        return selectedProvince != nil
        && selectedCounty != nil
        && selectedMunicipality != nil
        && isSectionNumberCorrect
    }
    
    var isSectionNumberCorrect: Bool {
        guard let sectionId, let selectedMunicipality else { return false }
        return sectionId >= 0
    }
    
    var selectedCountyName: String? {
        guard let selectedCounty else { return nil }
        return selectedCounty.name
    }
    
    var hasVisitedAnyStations: Bool {
        DB.shared.getVisitedSections().count > 0
    }
    
    /// Be notified when the API download state has changed
    var onDownloadStateChanged: (() -> Void)?
    
    /// Be notified when the API save state has changed
    var onSaveStateChanged: (() -> Void)?
    
    /// Be notified whenever the model data changes so you can update the interface with fresh data
    var onStateChanged: (() -> Void)?

    private(set) var provinces: [ProvinceResponse] = []

    private var countiesByProvince: [String: [CountyResponse]] = [:]

    private var municipalitiesByCounty: [String: [MunicipalityResponse]] = [:]
    
    var currentCounties: [CountyResponse]? { 
        guard let selectedProvince else { return nil }
        return countiesByProvince[selectedProvince.code]
    }
    
    var currentMunicipalities: [MunicipalityResponse]? {
        guard let selectedCounty else { return nil }
        return municipalitiesByCounty[selectedCounty.code]
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
    
    init(sectionId: String? = nil,
         province: ProvinceResponse? = nil,
         county: CountyResponse? = nil,
         municipality: MunicipalityResponse? = nil) {
        if let sectionId = sectionId {
            self.selectedProvince = province
            self.selectedCounty = county
            self.selectedMunicipality = municipality
            self.sectionId = Int(sectionId)
        } else {
            if let currentSection = DB.shared.currentSectionInfo() {
                self.selectedProvince = .basic(name: currentSection.provinceName,
                                             code: currentSection.provinceCode)
                self.selectedCounty = .basic(name: currentSection.countyName,
                                             code: currentSection.countyCode)
                self.selectedMunicipality = .basic(name: currentSection.municipalityName,
                                             code: currentSection.municipalityCode)
                self.sectionId = Int(currentSection.sectionId)
            }
        }
        super.init()
    }
    
    func fetchProvinces(then callback: @escaping (APIError?) -> Void) {
        isDownloading = true
        APIManager.shared.fetchProvinces { (provinces, error) in
            if let provinces = provinces {
                self.provinces = self.sorted(provinces)
                LocalStorage.shared.provinces = provinces
            }
            callback(error)
            self.isDownloading = false
        }
    }
    
    func fetchCounties(in province: String, then callback: @escaping (APIError?) -> Void) {
        isDownloading = true
        APIManager.shared.fetchCounties(for: province) { (counties, error) in
            if let counties = counties {
                self.countiesByProvince[province] = self.sorted(counties)
            }
            callback(error)
            self.isDownloading = false
        }
    }
    
    func fetchMunicipalities(in county: String, then callback: @escaping (APIError?) -> Void) {
        isDownloading = true
        APIManager.shared.fetchMunicipalities(for: county) { (municipalities, error) in
            if let municipalities {
                self.municipalitiesByCounty[county] = self.sorted(municipalities)
            }
            callback(error)
            self.isDownloading = false
        }
    }
    
    private func sorted<T: Sortable>(_ sortables: [T]) -> [T] {
        sortables.sorted(by: { s1, s2 in
            if s1.order != s2.order {
                // account for the order field
                return s1.order < s2.order
            } else {
                // fallback to alphabetically
                return s1.name < s2.name
            }
        })
    }
    
    func persist(then callback: @escaping (SectionPickerViewModelError?) -> Void) {
        guard let province = selectedProvince,
              let county = selectedCounty,
              let municipality = selectedMunicipality,
              let sectionId = sectionId else {
            callback(.genericError(reason: "Invalid section data provided"))
            return
        }
        
        var section = DB.shared.getSectionInfo(
            provinceCode: province.code,
            countyCode: county.code,
            municipalityCode: municipality.code,
            sectionId: sectionId
        )
        if section == nil {
            // create it
            section = DB.shared.createSectionInfo(
                provinceCode: province.code,
                provinceName: province.name,
                countyCode: county.code,
                countyName: county.name,
                municipalityCode: municipality.code,
                municipalityName: municipality.name,
                sectionId: sectionId
            )
        }
        
        guard let section else {
            callback(.genericError(reason: "Polling station data could not be fetched or created"))
            return
        }
        PreferencesManager.shared.province = province
        PreferencesManager.shared.county = county
        PreferencesManager.shared.municipality = municipality
        PreferencesManager.shared.section = sectionId
        PreferencesManager.shared.sectionName = section.sectionFullName
        callback(nil)
    }
    
}
