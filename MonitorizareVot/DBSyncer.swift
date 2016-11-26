// 2016 Code4Ro.

import UIKit
import CoreData

class DBSyncer: NSObject {

    func fetchNotes() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.predicate = NSPredicate(format: "synced == false")
        let notesToSyncArray = CoreData.fetch(request)
        //POST notes 
        self.deleteSyncedNotes(notesToDelete:notesToSyncArray)
    }
    
    func fetchAnswers() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.predicate = NSPredicate(format: "synced == false")
        let answersToSyncArray = CoreData.fetch(request)
        //POST answers & update synced value  
    }
    
    func deleteSyncedNotes( notesToDelete: [NSManagedObject]) {
        for aNote in notesToDelete {
            CoreData.context.delete(aNote)
        }
    }
    
}
