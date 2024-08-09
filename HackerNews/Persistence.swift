//
//  Persistence.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        return container.viewContext
    }

    init() {
        container = NSPersistentContainer(name: "HackerNews")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Error while loading persistence storage \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
