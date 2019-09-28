//
//  SectionDetailsViewModel.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 28/09/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import UIKit

class SectionDetailsViewModel: NSObject {
    var sectionName: String
    
    private(set) var sectionInfo: MVSectionInfo?
    private(set) var persistedSectionInfo: SectionInfo?
    private let dbSyncer = DBSyncer()
    private var sectionSaver = SectionSaver()

    var onUpdate: (() -> Void)?
    
    var medium: SectionInfo.Medium? {
        didSet {
            if let medium = medium {
                sectionInfo?.medium = medium.rawValue
                persistedSectionInfo?.medium = medium.rawValue
                try! CoreData.save()
            }
            onUpdate?()
        }
    }
    
    var gender: SectionInfo.Genre? {
       didSet {
           if let gender = gender {
               sectionInfo?.genre = gender.rawValue
               persistedSectionInfo?.genre = gender.rawValue
               try! CoreData.save()
           }
           onUpdate?()
       }
    }
    
    var arrivalTime: String? {
        didSet {
            if let time = arrivalTime {
                let components = time.components(separatedBy: ":")
                let hour = components[0]
                let minutes = components[1]
                sectionInfo?.arriveHour = hour
                sectionInfo?.arriveMinute = minutes
                persistedSectionInfo?.arriveHour = hour
                persistedSectionInfo?.arriveMinute = minutes
                try! CoreData.save()
            }
            onUpdate?()
        }
    }
    
    var departureTime: String? {
           didSet {
               if let time = departureTime {
                   let components = time.components(separatedBy: ":")
                   let hour = components[0]
                   let minutes = components[1]
                   sectionInfo?.leftHour = hour
                   sectionInfo?.leftMinute = minutes
                   persistedSectionInfo?.leftHour = hour
                   persistedSectionInfo?.leftMinute = minutes
                   try! CoreData.save()
               }
               onUpdate?()
           }
       }

    init(withSectionInfo sectionInfo: MVSectionInfo) {
        self.sectionInfo = sectionInfo
        if let medium = sectionInfo.medium {
            self.medium = SectionInfo.Medium(rawValue: medium)
        }
        if let gender = sectionInfo.genre {
            self.gender = SectionInfo.Genre(rawValue: gender)
        }
        self.arrivalTime = "\(sectionInfo.arriveHour):\(sectionInfo.arriveMinute)"
        self.departureTime = "\(sectionInfo.leftHour):\(sectionInfo.leftMinute)"
        self.sectionName = sectionInfo.judet! + " " + String(sectionInfo.sectie!)
        persistedSectionInfo = dbSyncer.sectionInfo(
            for: sectionInfo.judet!, sectie: sectionInfo.sectie!)
        super.init()
    }
    
    func persist(then callback: @escaping (_ success: Bool, _ tokenExpired: Bool) -> Void) {
        sectionSaver.persistedSectionInfo = persistedSectionInfo
        sectionSaver.save(
            sectionInfo: sectionInfo!,
            completion: callback)

    }
}
