//
//  InjectionManager.swift
//  Injector
//
//  Created by Trevor Behlman on 5/20/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import CoreData

class InjectionStorage {
    static let shared = InjectionStorage()
    
    let persistentContainer: NSPersistentContainer
    let injectionContext: NSManagedObjectContext
    let injectionEntity: NSEntityDescription
    
    private var appContext: InjectorContext?
    private let injectionsDidChangeEvent = Event()
    
    private init() {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        persistentContainer = InjectorSharedPersistentContainer(name: "Injector")
        if #available(OSX 10.15, *) {
            let description = persistentContainer.persistentStoreDescriptions.first!
            description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        }
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
    
    @available(OSX 10.15, *)
    func observeInjectionChanges(forContext context: InjectorContext) -> Event? {
        if appContext != nil {
            return nil
        }
        
        appContext = context
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(persistentStoreDidReceiveRemoteChange),
            name: .NSPersistentStoreRemoteChange, 
            object: persistentContainer.persistentStoreCoordinator
        )
        
        return injectionsDidChangeEvent
    }
    
    @objc
    @available(OSX 10.15, *)
    fileprivate func persistentStoreDidReceiveRemoteChange() {
        injectionContext.performAndWait {
            if mergeHistory() {
                deleteHistory()
            }
        }
    }
    
    private func mergeHistory() -> Bool {
        let request = NSPersistentHistoryChangeRequest
            .fetchHistory(after: appContext!.lastHistoryTransactionTimestamp ?? .distantPast)
        
        let result = try? injectionContext.execute(request) as? NSPersistentHistoryResult
        
        guard 
            let history = result?.result as? [NSPersistentHistoryTransaction],
            !history.isEmpty
        else { return false }
        
        var changedObjectIDs = Set<NSManagedObjectID>()
        
        for transaction in history {
            if let userInfo = transaction.objectIDNotification().userInfo {
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [injectionContext])
            }
            transaction.changes?.forEach() { change in
                changedObjectIDs.insert( change.changedObjectID )
            }
        }
        
        appContext!.lastHistoryTransactionTimestamp = history.last!.timestamp
        
        if !changedObjectIDs.isEmpty {
            injectionsDidChangeEvent.trigger()
        }
        
        return true
    }
    
    private func deleteHistory() {
        let timestamp = InjectorContext.allCases
            .map { $0.lastHistoryTransactionTimestamp ?? .distantPast }
            .min() ?? .distantPast
        let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: timestamp)
        let _ = try? injectionContext.execute(deleteHistoryRequest)
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
