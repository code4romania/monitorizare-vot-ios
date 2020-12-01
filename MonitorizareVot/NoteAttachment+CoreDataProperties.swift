//
//  NoteAttachment+CoreDataProperties.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 01/12/2020.
//  Copyright © 2020 Code4Ro. All rights reserved.
//

import Foundation
import CoreData


extension NoteAttachment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteAttachment> {
        return NSFetchRequest<NoteAttachment>(entityName: "NoteAttachment");
    }

    @NSManaged public var data: Data?
    @NSManaged public var localFilename: String?
    @NSManaged public var pickDate: Date?
    
    @NSManaged public var parentNote: Note?

}
