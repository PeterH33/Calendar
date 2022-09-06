//
//  Persistence.swift
//  Calendar
//
//  Created by Peter Hartnett on 8/31/22.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let databaseName = "Calendar.sqlite"
    
    var oldStoreURL: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(databaseName)
    }
    
    //data merge to new shared container
    var shardStoreURL: URL{
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.net.peterh.Calendar")!
        return container.appendingPathComponent(databaseName)
    }

    //preview has dummy data
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let startDate = Calendar.current.dateInterval(of: .month, for: .now)!.start
        
        for dayOffset in 0..<30 {
            let newDay = Day(context: viewContext)
            newDay.date = Calendar.current.date(byAdding: .day, value: dayOffset, to: startDate)
            newDay.didStudy = Bool.random()
        }
        do {
            try viewContext.save()
        } catch {
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    
    

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        
        container = NSPersistentContainer(name: "Calendar")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            //if there is nothing at oldstoreURL
        } else if !FileManager.default.fileExists(atPath: oldStoreURL.path){
            //part of data merge from live programs
            container.persistentStoreDescriptions.first!.url = shardStoreURL
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
               
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        //migrate is called every time, but the guard statement inside of it will prevent migration when oldstore is empty
        migrateStore(for: container)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func migrateStore(for container: NSPersistentContainer){
        let coordinator = container.persistentStoreCoordinator
        
        // check to see if there is something in the old store
        guard let oldStore = coordinator.persistentStore(for: oldStoreURL) else { return}
        
        do {
            // the let _ is to remove a warning, the return value shouldn't be needed.
            let _ = try coordinator.migratePersistentStore(oldStore, to: shardStoreURL, type: .sqlite)
        } catch {
            //Fatal error, might not be a great idea in full app.
            fatalError("Unable to migrate to shared store")
        }
        
        do{
            try FileManager.default.removeItem(at: oldStoreURL)
        } catch{
            print("error Unable to delete old store")
        }
    }
}
