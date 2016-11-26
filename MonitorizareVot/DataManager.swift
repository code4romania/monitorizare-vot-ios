//
//  DataManager.swift
//  MonitorizareVot
//
//  Created by Ilinca Ispas on 19/11/2016.
//  Copyright © 2016 Code4Ro. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
        var managedObjectContext: NSManagedObjectContext
        override init() {
            // This resource is the same name as your xcdatamodeld contained in your project.
            guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension:"momd") else {
                fatalError("Error loading model from bundle")
            }
            // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Error initializing mom from: \(modelURL)")
            }
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = psc
            
            DispatchQueue.global().async {
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let docURL = urls[urls.endIndex-1]
                /* The directory the application uses to store the Core Data store file.
                 This code uses a file named "DataModel.sqlite" in the application's documents directory.
                 */
                let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
                do {
                    try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                } catch {
                    fatalError("Error migrating store: \(error)")
                }

            }
    }
}
