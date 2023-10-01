//
//  SectionInfo+CoreDataProperties.swift
//  MonitorizareVot
//
//  Created by Corneliu Chitanu on 08/12/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import CoreData


extension SectionInfo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionInfo> {
        return NSFetchRequest<SectionInfo>(entityName: "SectionInfo");
    }

    @NSManaged public var provinceCode: String?
    @NSManaged public var provinceName: String?
    @NSManaged public var countyCode: String?
    @NSManaged public var countyName: String?
    @NSManaged public var municipalityCode: String?
    @NSManaged public var municipalityName: String?
    @NSManaged public var sectionId: Int64
    @NSManaged public var synced: Bool
    
    @NSManaged public var leaveTime: Date?
    @NSManaged public var arriveTime: Date?
    @NSManaged public var numberOfVotersOnTheList: Int64
    @NSManaged public var numberOfCommissionMembers: Int64
    @NSManaged public var numberOfFemaleMembers: Int64
    @NSManaged public var minPresentMembers: Int64
    @NSManaged public var chairmanPresence: Bool
    @NSManaged public var singlePollingStationOrCommission: Bool
    @NSManaged public var adequatePollingStationSize: Bool
    
    @NSManaged public var notes: NSSet?
    @NSManaged public var questions: NSSet?
}

// MARK: Generated accessors for notes
extension SectionInfo {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: Note)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: Note)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}

// MARK: Generated accessors for questions
extension SectionInfo {

    @objc(addQuestionsObject:)
    @NSManaged public func addToQuestions(_ value: Question)

    @objc(removeQuestionsObject:)
    @NSManaged public func removeFromQuestions(_ value: Question)

    @objc(addQuestions:)
    @NSManaged public func addToQuestions(_ values: NSSet)

    @objc(removeQuestions:)
    @NSManaged public func removeFromQuestions(_ values: NSSet)

}

extension SectionInfo {
    var sectionFullName: String? {
        guard let countyName = self.countyName,
              let municipalityName = self.municipalityName else { return nil }
        return "Station".localized + " \(sectionId) \(municipalityName.capitalized), \(countyName.capitalized)"
    }
}
