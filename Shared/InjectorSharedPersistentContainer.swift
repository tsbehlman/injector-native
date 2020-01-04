//
//  InjectorSharedPersistentContainer.swift
//  Injector
//
//  Created by Trevor Behlman on 5/15/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import CoreData

class InjectorSharedPersistentContainer: NSPersistentContainer {
    override open class func defaultDirectoryURL() -> URL {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "VE6CSLGJ83.com.tbehlman.Injector")!
    }
}
