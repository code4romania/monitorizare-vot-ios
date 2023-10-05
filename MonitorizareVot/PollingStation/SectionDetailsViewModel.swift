//
//  SectionDetailsViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class SectionDetailsViewModel: NSObject {
    
    var onUpdate: (() -> Void)?
    
    var isReady: Bool {
        return arrivalTime != nil
        && isValid(int: numberOfVotersOnTheList)
        && isValid(int: numberOfCommissionMembers)
        && isValid(int: numberOfFemaleMembers)
        && isValid(int: minPresentMembers)
        && isValid(bool: chairmanPresence)
        && isValid(bool: singlePollingStationOrCommission)
        && isValid(bool: adequatePollingStationSize)
    }
    
    private func isValid(int: Int?) -> Bool {
        int != nil && int! >= 0 && int! <= Int(Int64.max)
    }
    
    private func isValid(bool: Bool?) -> Bool {
        bool != nil
    }
    
    var arrivalTime: Date? {
        didSet {
            onUpdate?()
        }
    }
    
    var leaveTime: Date? {
        didSet {
            onUpdate?()
        }
    }
    
    var numberOfVotersOnTheList: Int? {
        didSet {
            onUpdate?()
        }
    }
    
    var numberOfCommissionMembers: Int? {
        didSet {
            onUpdate?()
        }
    }
    
    var numberOfFemaleMembers: Int? {
        didSet {
            onUpdate?()
        }
    }
    
    var minPresentMembers: Int? {
        didSet {
            onUpdate?()
        }
    }
    
    var chairmanPresence: Bool? {
        didSet {
            onUpdate?()
        }
    }
    
    var singlePollingStationOrCommission: Bool? {
        didSet {
            onUpdate?()
        }
    }
    
    var adequatePollingStationSize: Bool? {
        didSet {
            onUpdate?()
        }
    }
    
    override init() {
        let sectionInfo = DB.shared.currentSectionInfo()
        if let sectionInfo {
            self.arrivalTime = sectionInfo.arriveTime
            self.leaveTime = sectionInfo.leaveTime
            self.numberOfVotersOnTheList = Int(sectionInfo.numberOfVotersOnTheList)
            self.numberOfCommissionMembers = Int(sectionInfo.numberOfCommissionMembers)
            self.numberOfFemaleMembers = Int(sectionInfo.numberOfFemaleMembers)
            self.minPresentMembers = Int(sectionInfo.minPresentMembers)
            self.chairmanPresence = sectionInfo.chairmanPresence
            self.singlePollingStationOrCommission = sectionInfo.singlePollingStationOrCommission
            self.adequatePollingStationSize = sectionInfo.adequatePollingStationSize
        }
        super.init()
    }
    
    private func saveLocally() {
        let sectionInfo = DB.shared.currentSectionInfo()
        if sectionInfo == nil { return }
        
        if let time = arrivalTime {
            sectionInfo?.arriveTime = time
        }
        if let time = leaveTime {
            sectionInfo?.leaveTime = time
        }
        sectionInfo?.numberOfVotersOnTheList = Int64(numberOfVotersOnTheList ?? 0)
        sectionInfo?.numberOfCommissionMembers = Int64(numberOfCommissionMembers ?? 0)
        sectionInfo?.numberOfFemaleMembers = Int64(numberOfFemaleMembers ?? 0)
        sectionInfo?.minPresentMembers = Int64(minPresentMembers ?? 0)
        sectionInfo?.chairmanPresence = chairmanPresence ?? false
        sectionInfo?.singlePollingStationOrCommission = singlePollingStationOrCommission ?? false
        sectionInfo?.adequatePollingStationSize = adequatePollingStationSize ?? false

        sectionInfo?.synced = false
        try! CoreData.save()
    }
    
    func persist(then callback: @escaping (_ error: RemoteSyncerError?, _ tokenExpired: Bool) -> Void) {
        
        saveLocally()
        
        guard let section = DB.shared.currentSectionInfo(),
            !section.synced else {
            callback(nil, false)
            return
        }
        
        RemoteSyncer.shared.uploadSectionInfo(section) { error in
            DebugLog("Uploaded section info. Error: \(error?.localizedDescription ?? "None")")
            switch error {
            case .noteError(let reason):
                if case .unauthorized = reason {
                    callback(error, true)
                    return
                }
            default:
                break
            }
            callback(error, false)
        }
    }
}
