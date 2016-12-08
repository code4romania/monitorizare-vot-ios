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

    @NSManaged public var arriveHour: String?
    @NSManaged public var arriveMinute: String?
    @NSManaged public var genre: String?
    @NSManaged public var judet: String?
    @NSManaged public var leftHour: String?
    @NSManaged public var leftMinute: String?
    @NSManaged public var medium: String?
    @NSManaged public var sectie: String?
    @NSManaged public var synced: Bool
    @NSManaged public var note: NSSet?
    @NSManaged public var questions: NSSet?

}

// MARK: Generated accessors for note
extension SectionInfo {

    @objc(addNoteObject:)
    @NSManaged public func addToNote(_ value: Note)

    @objc(removeNoteObject:)
    @NSManaged public func removeFromNote(_ value: Note)

    @objc(addNote:)
    @NSManaged public func addToNote(_ values: NSSet)

    @objc(removeNote:)
    @NSManaged public func removeFromNote(_ values: NSSet)

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
