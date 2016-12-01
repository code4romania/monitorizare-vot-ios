// 2016 Code4Ro.

import UIKit
import CoreData

class DBSyncer: NSObject {
    
    private let noteSaver = NoteSaver()

    func fetchNotes() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.predicate = NSPredicate(format: "synced == false")
        let notesToSyncArray = CoreData.fetch(request)
        let notesForSaver = parseNotesFromDB(notesToParse: notesToSyncArray)
        noteSaver.save(notes: notesForSaver)
        self.deleteSyncedNotes(notesToDelete:notesToSyncArray)
    }
    
    func fetchAnswers() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        request.predicate = NSPredicate(format: "synced == false")
        let answersToSyncArray = CoreData.fetch(request)
        //POST answers & update synced value  
    }
    
    private func deleteSyncedNotes( notesToDelete: [NSManagedObject]) {
        for aNote in notesToDelete {
            CoreData.context.delete(aNote)
        }
    }
    
    private func parsePresidingOfficer(presidingOfficer: NSManagedObject) -> MVPresidingOfficer {
        let aPresidingOfficer = MVPresidingOfficer()
        if let arriveHour = presidingOfficer.value(forKey: "arriveHour") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = "00"
        }
        if let arriveHour = presidingOfficer.value(forKey: "arriveMinute") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = "00"
        }
        if let arriveHour = presidingOfficer.value(forKey: "genre") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = ""
        }
        if let arriveHour = presidingOfficer.value(forKey: "judet") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = ""
        }
        if let arriveHour = presidingOfficer.value(forKey: "sectie") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = ""
        }
        if let arriveHour = presidingOfficer.value(forKey: "medium") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = ""
        }
        if let arriveHour = presidingOfficer.value(forKey: "leftHour") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = "00"
        }
        if let arriveHour = presidingOfficer.value(forKey: "leftMinute") as? String {
            aPresidingOfficer.arriveHour = arriveHour
        } else {
            aPresidingOfficer.arriveHour = "00"
        }
        return aPresidingOfficer
    }
    
    private func parseNotesFromDB(notesToParse: [NSManagedObject]) -> [MVNote] {
        var notes = [MVNote]()
        for  i in 0...notesToParse.count-1 {
            if let aNote = notesToParse[i] as? NSManagedObject {
                var aPresidingOfficer = MVPresidingOfficer()
                if let presidingOfficer = aNote.value(forKey: "presidingOfficer") as? NSManagedObject{
                    let note = MVNote(presidingOfficer: parsePresidingOfficer(presidingOfficer: presidingOfficer))
                if let body = aNote.value(forKey: "body") as? String {
                    note.body = body
                } else {
                    note.body = ""
                }
                if let file = aNote.value(forKey: "file") as? Data {
                    let image = UIImage(data: file)
                    note.image = image
                }
                if let questionID = aNote.value(forKey: "questionID") as? String {
                    note.questionID = questionID
                } else {
                    note.questionID = ""
                }
                if let synced = aNote.value(forKey: "synced") as? Bool {
                    note.synced = synced
                } else {
                    note.synced = false
                }
                notes.append(note)
                }
            }
        }
        return notes
    }
    
}
