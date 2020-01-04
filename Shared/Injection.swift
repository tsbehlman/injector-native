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
        self.init(entity: InjectionManager.shared.injectionEntity, insertInto: InjectionManager.shared.injectionContext)
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
    
    public func matchesURL(_ url: URL) -> Bool {
        return matchesURL(url, using: includes) && !matchesURL(url, using: excludes)
    }
    
    fileprivate func matchesURL(_ url: URL, using patterns: [String]) -> Bool {
        for pattern in patterns {
            let escapedPattern = NSRegularExpression.escapedPattern(for: pattern)
            let patternRegex = try! escapedPattern.replacing(pattern: #"(?<!\\)\\[*?]"#) { 
                if $0 == "\\*" {
                    return ".*?"
                } else if $0 == "\\?" {
                    return "?"
                } else {
                    return $0
                }
            }
            if normalizeURL(url).absoluteString.matches(pattern: patternRegex) {
                return true
            }
        }
        return false;
    }
}

func normalizeURL(_ url: URL) -> URL {
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    if components.host!.starts(with: "www.") {
        components.host = components.host![4..<components.host!.count]
    }
    if components.path.count == 0 {
        components.path = "/"
    }
    return components.url!
}
