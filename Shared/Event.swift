//
//  Event.swift
//  Injector
//
//  Created by Trevor Behlman on 1/2/20.
//  Copyright © 2020 Trevor Behlman. All rights reserved.
//

import Foundation

class Event<Payload> {
    private var observers = [(Payload) -> Void]()
    
    func addObserver(using closure: @escaping (Payload) -> Void) {
        observers.append(closure)
    }
    
    func trigger(_ payload: Payload) {
        for observer in observers {
            observer(payload)
        }
    }
}
