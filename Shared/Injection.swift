//
//  Injection.swift
//  Injector
//
//  Created by Trevor Behlman on 5/27/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import CoreData

@objc(Injection)
final class Injection: NSManagedObject, Encodable {
    @NSManaged var isEnabled: Bool
    @NSManaged var name: String
    @NSManaged var includes: [String]
    @NSManaged var excludes: [String]
    @NSManaged var styles: String
    @NSManaged var script: String
    @NSManaged var scriptLoadBehavior: Int16
    
    enum CodingKeys: String, CodingKey {
        case id
        case isEnabled
        case name
        case includes
        case excludes
        case styles
        case script
        case scriptLoadBehavior
    }
    
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.objectID.uriRepresentation().absoluteString, forKey: .id)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(name, forKey: .name)
        try container.encode(includes, forKey: .includes)
        try container.encode(excludes, forKey: .excludes)
        try container.encode(styles, forKey: .styles)
        try container.encode(script, forKey: .script)
        try container.encode(scriptLoadBehavior, forKey: .scriptLoadBehavior)
    }
}
