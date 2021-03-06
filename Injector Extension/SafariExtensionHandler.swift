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
            if let injectionsDidChangeEvent = InjectionStorage.shared.observeInjectionChanges(forContext: .safariExtension) {
                injectionsDidChangeEvent.addObserver() {
                    SafariExtensionHandler.updateAllPages()
                }
            }
        }
    }
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        if messageName == "update" {
            let injections = InjectionStorage.shared.getEnabledInjections()
            SafariExtensionHandler.update(page: page, withInjections: injections)
        }
    }
    
    static func updateAllPages() {
        let injections = InjectionStorage.shared.getEnabledInjections()
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
            page.dispatchMessageToScript(
                withName: "update",
                userInfo: ["injections": injections
                    .filter { $0.matchesURL(url) }
                    .map { $0.toDictionary() }
                ]
            )
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
