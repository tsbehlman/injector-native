//
//  AppDelegate.swift
//  Injector
//
//  Created by Trevor Behlman on 5/5/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let window = NSWindow(contentViewController: InjectionManagerController())
        window.makeKeyAndOrderFront(self)
    }
}
