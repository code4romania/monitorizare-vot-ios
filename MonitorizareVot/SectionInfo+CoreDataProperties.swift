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
    
    enum Medium: String {
        case urban
        case rural
    }
    
    enum Genre: String {
        case woman
        case man
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SectionInfo> {
        return NSFetchRequest<SectionInfo>(entityName: "SectionInfo");
    }

    @NSManaged public var countyCode: String?
    @NSManaged public var sectionId: Int16
    @NSManaged public var presidentGender: String?
    @NSManaged public var medium: String?
    @NSManaged public var synced: Bool
    @NSManaged public var leaveTime: Date?
    @NSManaged public var arriveTime: Date?

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
