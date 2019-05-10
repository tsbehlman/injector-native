//
//  TableActionView.swift
//  Injector
//
//  Created by Trevor Behlman on 5/7/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import Cocoa
import SnapKit

class TableActionView: NSViewController {
    let scrollView = NSScrollView();
    let tableView = NSTableView()
    let buttonBar = NSSegmentedControl()
    let buttonBarBackground = NSButton(title: " ", target: nil, action: nil)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view = NSView()
        
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.rowSizeStyle = .large
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column"))
        tableView.headerView = nil
        column.width = 1
        tableView.addTableColumn(column)
        scrollView.documentView = tableView
        tableView.snp.makeConstraints() { make in
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(100)
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints() { make in
            make.top.equalToSuperview().priority(NSLayoutConstraint.Priority.windowSizeStayPut.rawValue - 1)
            make.left.right.equalToSuperview()
        }
        
        buttonBarBackground.bezelStyle = .smallSquare
        buttonBarBackground.setButtonType(.momentaryChange)
        view.addSubview(buttonBarBackground)
        buttonBarBackground.snp.makeConstraints() { make in
            make.bottom.equalToSuperview().offset(1)
            make.right.equalToSuperview().offset(1)
            make.top.equalTo(scrollView.snp.bottom)
            
        }
        
        buttonBar.segmentStyle = .smallSquare
        buttonBar.segmentCount = 2
        buttonBar.setImage(NSImage(named: "NSAddTemplate"), forSegment: 0)
        buttonBar.setImage(NSImage(named: "NSRemoveTemplate"), forSegment: 1)
        view.addSubview(buttonBar)
        buttonBar.snp.makeConstraints() { make in
            make.bottom.equalToSuperview().offset(1)
            make.left.equalToSuperview().offset(-1)
            make.right.equalTo(buttonBarBackground.snp.left).inset(1)
            make.top.equalTo(scrollView.snp.bottom)
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
