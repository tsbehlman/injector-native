//
//  InjectionManager.swift
//  Injector
//
//  Created by Trevor Behlman on 5/20/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import CoreData

class InjectionManager {
    static let shared = InjectionManager()
    
    let persistentContainer: NSPersistentContainer
    let injectionContext: NSManagedObjectContext
    let injectionEntity: NSEntityDescription
    
    private init() {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        persistentContainer = InjectorSharedPersistentContainer(name: "Injector")
        let description = persistentContainer.persistentStoreDescriptions.first!
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        description.setOption(true as NSNumber, forKey: remoteChangeKey)
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        
        injectionContext = persistentContainer.viewContext
        injectionEntity = NSEntityDescription.entity(forEntityName: "Injection", in: injectionContext)!
    }
    
    
    
    func getInjections() -> [Injection] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Injection")
        
        do {
            return try injectionContext.fetch(request) as! [Injection]
        } catch {
            print("InjectionManager failed to list injections")
        }
        
        return []
    }
    
    func getEnabledInjections() -> [Injection] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Injection")
        request.predicate = NSPredicate(format: "isEnabled == true")
        
        do {
            let result = try injectionContext.fetch(request)
            return result as! [Injection]
        } catch {
            print("InjectionManager failed to list injections")
        }
        
        return []
    }
    
    func getInjection(_ id: String) throws -> Injection {
        let objectID = injectionContext.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: URL(string: id)!)!
        return try injectionContext.existingObject(with: objectID) as! Injection
    }
}
