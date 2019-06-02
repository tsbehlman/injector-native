//
//  Injection.swift
//  Injector
//
//  Created by Trevor Behlman on 5/27/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import CoreData

@objc(Injection)
final class Injection: NSManagedObject {
    @NSManaged var isEnabled: Bool
    @NSManaged var name: String
    @NSManaged var includes: [String]
    @NSManaged var excludes: [String]
    @NSManaged var styles: String
    @NSManaged var script: String
    @NSManaged var scriptLoadBehavior: Int16
    
    convenience init(from values: [String: Any]) {
        self.init(entity: InjectionManager.injectionEntity, insertInto: InjectionManager.context)
        update(from: values)
    }
    
    public func update(from values: [String: Any]) {
        isEnabled = values["isEnabled"] as! Bool
        name = values["name"] as! String
        includes = values["includes"] as! [String]
        excludes = values["excludes"] as! [String]
        styles = values["styles"] as! String
        script = values["script"] as! String
        scriptLoadBehavior = values["scriptLoadBehavior"] as! Int16
    }
    
    public func toDictionary() -> [String: Any] {
        var values = [String: Any]()
        values["id"] = self.objectID.uriRepresentation().absoluteString
        values["isEnabled"] = isEnabled
        values["name"] = name
        values["includes"] = includes
        values["excludes"] = excludes
        values["styles"] = styles
        values["script"] = script
        values["scriptLoadBehavior"] = scriptLoadBehavior
        return values
    }
    
}
