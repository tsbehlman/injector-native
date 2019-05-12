//
//  ViewController.swift
//  Injector
//
//  Created by Trevor Behlman on 5/5/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import Cocoa
import SnapKit

class InjectionManagerController: NSViewController {
    override func loadView() {
        let splitView = NSSplitView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        view = splitView
        
        let tableViewController = TableActionViewController()
        addChild(tableViewController)
        splitView.addSubview(tableViewController.view)
        tableViewController.view.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(150).priority(500)
            make.width.lessThanOrEqualTo(view).dividedBy(2).priority(500)
        }
        
        splitView.addSubview(NSView())
    }
}
