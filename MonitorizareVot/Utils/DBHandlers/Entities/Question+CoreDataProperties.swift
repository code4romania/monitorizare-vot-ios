//
//  Question+CoreDataProperties.swift
//  MonitorizareVot
//
//  Created by Corneliu Chitanu on 08/12/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import CoreData


extension Question {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question");
    }

    @NSManaged public var answered: Bool
    @NSManaged public var form: String?
    @NSManaged public var formVersion: Int16
    @NSManaged public var id: Int16
    @NSManaged public var synced: Bool
    @NSManaged public var text: String?
    @NSManaged public var type: Int16
    @NSManaged public var answers: NSSet?
    @NSManaged public var sectionInfo: SectionInfo?
    @NSManaged public var note: Note?

}

// MARK: Generated accessors for answers
extension Question {

    @objc(addAnswersObject:)
    @NSManaged public func addToAnswers(_ value: Answer)

    @objc(removeAnswersObject:)
    @NSManaged public func removeFromAnswers(_ value: Answer)

    @objc(addAnswers:)
    @NSManaged public func addToAnswers(_ values: NSSet)

    @objc(removeAnswers:)
    @NSManaged public func removeFromAnswers(_ values: NSSet)

}
