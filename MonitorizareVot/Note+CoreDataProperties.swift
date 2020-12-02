//
//  Note+CoreDataProperties.swift
//  MonitorizareVot
//
//  Created by Corneliu Chitanu on 08/12/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note");
    }

    @NSManaged public var body: String?
    @NSManaged public var questionID: Int16
    @NSManaged public var file: NSData?
    @NSManaged public var synced: Bool
    @NSManaged public var sectionInfo: SectionInfo?
    @NSManaged public var date: Date?

    @NSManaged public var attachments: NSOrderedSet?

}

// MARK: Generated accessors for attachments
extension Note {

    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: NoteAttachment)

    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: NoteAttachment)

    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSOrderedSet)

    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSOrderedSet)

}
