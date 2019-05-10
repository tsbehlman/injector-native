//
//  SafariExtensionViewController.swift
//  Injector Extension
//
//  Created by Trevor Behlman on 5/5/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared: SafariExtensionViewController = {
        let shared = SafariExtensionViewController()
        shared.preferredContentSize = NSSize(width:320, height:240)
        return shared
    }()

}
