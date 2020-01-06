//
//  Event.swift
//  Injector
//
//  Created by Trevor Behlman on 1/2/20.
//  Copyright © 2020 Trevor Behlman. All rights reserved.
//

import Foundation

class Event {
    private var observers = [() -> Void]()
    
    func addObserver(using closure: @escaping () -> Void) {
        observers.append(closure)
    }
    
    func trigger() {
        for observer in observers {
            observer()
        }
    }
}
