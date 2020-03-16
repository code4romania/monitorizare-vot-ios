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
        return medium != nil && gender != nil && arrivalTime != nil
    }
    
    var medium: SectionInfo.Medium? {
        didSet {
            if let medium = medium {
                DB.shared.currentSectionInfo()?.medium = medium.rawValue
                try! CoreData.save()
            }
            onUpdate?()
        }
    }
    
    var gender: SectionInfo.Genre? {
       didSet {
           if let gender = gender {
               DB.shared.currentSectionInfo()?.presidentGender = gender.rawValue
               try! CoreData.save()
           }
           onUpdate?()
       }
    }
    
    var arrivalTime: Date? {
        didSet {
            if let time = arrivalTime {
                DB.shared.currentSectionInfo()?.arriveTime = time
                DB.shared.currentSectionInfo()?.synced = false
                try! CoreData.save()
            }
            onUpdate?()
        }
    }
    
    var leaveTime: Date? {
        didSet {
            if let time = leaveTime {
                DB.shared.currentSectionInfo()?.leaveTime = time
                DB.shared.currentSectionInfo()?.synced = false
                try! CoreData.save()
            }
            onUpdate?()
        }
    }
    
    override init() {
        let sectionInfo = DB.shared.currentSectionInfo()
        if let medium = sectionInfo?.medium {
            self.medium = SectionInfo.Medium(rawValue: medium)
        }
        if let gender = sectionInfo?.presidentGender {
            self.gender = SectionInfo.Genre(rawValue: gender)
        }
        self.arrivalTime = sectionInfo?.arriveTime
        self.leaveTime = sectionInfo?.leaveTime
        super.init()
    }
    
    func persist(then callback: @escaping (_ error: RemoteSyncerError?, _ tokenExpired: Bool) -> Void) {
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
