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
    @NSManaged public var file: NSData?
    @NSManaged public var questionID: Int16
    @NSManaged public var synced: Bool
    @NSManaged public var sectionInfo: SectionInfo?
    @NSManaged public var date: Date?

}
