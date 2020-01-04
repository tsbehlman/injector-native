//
//  InjectorContext.swift
//  Injector
//
//  Created by Trevor Behlman on 1/2/20.
//  Copyright © 2020 Trevor Behlman. All rights reserved.
//

import Foundation

enum InjectorContext: String, CaseIterable {
    case manager, safariExtension
    
    func lastHistoryTransactionTimestampKey() -> String {
        "lastHistoryTransactionTimestamp-\(self)"
    }
    
    var lastHistoryTransactionTimestamp: Date? {
        get {
            InjectionDefaults.shared.object(forKey: lastHistoryTransactionTimestampKey()) as? Date
        }
        set {
            InjectionDefaults.shared.set(newValue, forKey: lastHistoryTransactionTimestampKey())
            InjectionDefaults.shared.synchronize()
        }
    }
}
