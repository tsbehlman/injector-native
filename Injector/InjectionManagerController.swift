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
    let splitView = NSSplitView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
    let tableViewController = TableActionView()
    let editView = NSView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view = splitView
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        
        addChild(tableViewController)
        let tableView = tableViewController.view
        splitView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(150).priority(750)
            make.width.lessThanOrEqualTo(view).dividedBy(2).priority(249)
        }
        
        splitView.addSubview(editView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
