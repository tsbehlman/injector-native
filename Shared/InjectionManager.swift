//
//  InjectionManager.swift
//  Injector
//
//  Created by Trevor Behlman on 5/20/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import CoreData

class InjectionManager {
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = InjectorSharedPersistentContainer(name: "Injector")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
        return container
    }()
    
    static var context = {
        return InjectionManager.persistentContainer.viewContext
    }()
    
    static var injectionEntity = {
        return NSEntityDescription.entity(forEntityName: "Injection", in: InjectionManager.context)
    }()
    
    open class func getInjections() -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Injection")
        
        do {
            let result = try InjectionManager.context.fetch(request)
            return result as! [NSManagedObject]
        } catch {
            print("InjectionManager failed to list injections")
        }
        
        return []
    }
}
