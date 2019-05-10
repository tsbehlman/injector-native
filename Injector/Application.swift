//
//  InjectorApp.swift
//  Injector
//
//  Created by Trevor Behlman on 5/5/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import Cocoa

class Application: NSApplication {
    let strongDelegate = AppDelegate()
    
    override init() {
        super.init()
        self.delegate = strongDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
