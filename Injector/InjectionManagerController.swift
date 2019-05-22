//
//  ViewController.swift
//  Injector
//
//  Created by Trevor Behlman on 5/5/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import Cocoa
import WebKit

class InjectionManagerController: NSViewController {
    override func loadView() {
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        view = webView
        
        let managerURL = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "manager")!
        webView.loadFileURL(managerURL, allowingReadAccessTo: managerURL)
    }
}
