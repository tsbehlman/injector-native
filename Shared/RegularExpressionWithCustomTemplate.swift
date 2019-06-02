//
//  RegularExpressionWithCustomReplacement.swift
//  Injector
//
//  Created by Trevor Behlman on 6/1/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import Foundation

public typealias TemplateCallback = (_ match: String) -> String;

fileprivate class RegularExpressionWithCustomTemplate : NSRegularExpression {
    private var customTemplateString: TemplateCallback = { $0 };
    
    override func replacementString(for result: NSTextCheckingResult, in string: String, offset: Int, template templ: String) -> String {
        return customTemplateString(string[result.range.lowerBound..<result.range.upperBound])
    }
    
    public func useTemplate(_ customTemplate: @escaping TemplateCallback) {
        customTemplateString = customTemplate
    }
}

extension String {
    public func replacing(pattern: String, with template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
    }
    
    public func replacing(pattern: String, _ customTemplate: @escaping TemplateCallback) throws -> String {
        let regex = try RegularExpressionWithCustomTemplate(pattern: pattern)
        regex.useTemplate(customTemplate)
        let range = NSRange(location: 0, length: self.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
    }
    
    public func matches(pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    subscript(_ range: CountableRange<Int>) -> String { 
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end   = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[start..<end])
    }
}
