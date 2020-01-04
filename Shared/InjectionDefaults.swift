//
//  InjectionDefaults.swift
//  Injector
//
//  Created by Trevor Behlman on 1/2/20.
//  Copyright © 2020 Trevor Behlman. All rights reserved.
//

import Foundation

class InjectionDefaults: UserDefaults {
    static let shared = InjectionDefaults()
    
    private init() {
        super.init(suiteName: "VE6CSLGJ83.com.tbehlman.Injector")!
    }
}
