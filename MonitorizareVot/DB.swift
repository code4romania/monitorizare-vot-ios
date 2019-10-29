//
//  DB.swift
//  MonitorizareVot
//
//  Created by Cristi Habliuc on 29/10/2019.
//  Copyright © 2019 Code4Ro. All rights reserved.
//

import Foundation
import CoreData

class DB: NSObject {
    static let shared = DB()
    
    func currentSectionInfo() -> SectionInfo? {
        guard let county = PreferencesManager.shared.county,
            let stationId = PreferencesManager.shared.section else { return nil }
        return sectionInfo(for: county, sectie: stationId)
    }
    
    func sectionInfo(for judet: String, sectie:String) -> SectionInfo {
        let request: NSFetchRequest<SectionInfo> = SectionInfo.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "judet == %@ && sectie == %@", judet, sectie)
        let sections = try? CoreData.context.fetch(request)
        if let sectionInfo = sections?.first {
            return sectionInfo
        } else {
            // create it
            let sectionInfoEntityDescription = NSEntityDescription.entity(forEntityName: "SectionInfo", in: CoreData.context)
            let newSectioInfo = SectionInfo(entity: sectionInfoEntityDescription!, insertInto: CoreData.context)
            newSectioInfo.judet = judet
            newSectioInfo.sectie = sectie
            newSectioInfo.synced = false
            try! CoreData.context.save()
            return newSectioInfo
            
            // TODO: sync it!
        }
    }
    
    func getUnsyncedNotes() -> [Note] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sectionPredicate = NSPredicate(format: "section == %@", section)
        let syncedPredicate = NSPredicate(format: "synced == false")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, syncedPredicate])
        let unsyncedNotes = CoreData.fetch(request) as? [Note]
        return unsyncedNotes ?? []
    }
    
    func getUnsyncedQuestions() -> [Question] {
        guard let section = currentSectionInfo() else { return [] }
        let request: NSFetchRequest<Question> = Question.fetchRequest()
        let sectionPredicate = NSPredicate(format: "section == %@", section)
        let syncedPredicate = NSPredicate(format: "synced == false")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sectionPredicate, syncedPredicate])
        let unsyncedQuestions = CoreData.fetch(request) as? [Question]
        return unsyncedQuestions ?? []
    }
    
}
