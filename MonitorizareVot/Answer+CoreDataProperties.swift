//
//  Answer+CoreDataProperties.swift
//  MonitorizareVot
//
//  Created by Corneliu Chitanu on 08/12/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import Foundation
import CoreData


extension Answer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Answer> {
        return NSFetchRequest<Answer>(entityName: "Answer");
    }

    @NSManaged public var id: Int16
    @NSManaged public var inputAvailable: Bool
    @NSManaged public var inputText: String?
    @NSManaged public var selected: Bool
    @NSManaged public var text: String?
    @NSManaged public var question: Question?

}
