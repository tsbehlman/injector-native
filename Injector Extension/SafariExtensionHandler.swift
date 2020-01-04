//
//  SafariExtensionHandler.swift
//  Injector Extension
//
//  Created by Trevor Behlman on 5/5/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    override init() {
        super.init()
        
        if #available(OSXApplicationExtension 10.15, *) {
            if let injectionsDidChangeEvent = InjectionManager.shared.observeInjectionChanges(forContext: .safariExtension) {
                injectionsDidChangeEvent.addObserver() { changedInjections in
                    SafariExtensionHandler.updateAllPages(withInjections: changedInjections)
                }
            }
        }
    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        if messageName == "update" {
            let injections = InjectionManager.shared.getEnabledInjections()
            SafariExtensionHandler.update(page: page, withInjections: injections)
        }
    }
    
    static func updateAllPages(withInjections injections: [Injection]) {
        SFSafariApplication.getAllWindows { windows in
            for window in windows {
                window.getAllTabs { tabs in
                    for tab in tabs {
                        tab.getPagesWithCompletionHandler { pages in
                            for page in pages ?? [] {
                                SafariExtensionHandler.update(page: page, withInjections: injections)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private static func update(page: SFSafariPage, withInjections injections: [Injection]) {
        page.getPropertiesWithCompletionHandler { properties in
            guard let url = properties?.url else { return }
            let applicableInjections = injections
                .filter { $0.isEnabled && $0.matchesURL(url) }
            let userInfo = ["injections": applicableInjections
                .map { $0.toDictionary() }
            ]
            page.dispatchMessageToScript(withName: "update", userInfo: userInfo)
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        print("The extension's toolbar item was clicked")
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
