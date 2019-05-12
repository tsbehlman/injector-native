//
//  TableActionView.swift
//  Injector
//
//  Created by Trevor Behlman on 5/7/19.
//  Copyright © 2019 Trevor Behlman. All rights reserved.
//

import Cocoa
import SnapKit

class TableActionViewController: NSViewController {
    override func loadView() {
        view = NSView()
        
        let scrollView = NSScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints() { make in
            make.top.left.right.equalToSuperview()
        }
        
        let tableView = NSTableView()
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column"))
        column.width = 1
        tableView.addTableColumn(column)
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.rowSizeStyle = .large
        tableView.headerView = nil
        scrollView.documentView = tableView
        tableView.snp.makeConstraints() { make in
            make.left.right.equalToSuperview()
            make.height.greaterThanOrEqualTo(100)
        }
        
        let buttonBar = NSSegmentedControl()
        buttonBar.segmentStyle = .smallSquare
        buttonBar.segmentCount = 3
        buttonBar.trackingMode = .momentary
        buttonBar.segmentDistribution = .fillEqually
        buttonBar.setImage(NSImage(named: "NSAddTemplate"), forSegment: 0)
        buttonBar.setImage(NSImage(named: "NSRemoveTemplate"), forSegment: 1)
        buttonBar.setWidth(32, forSegment: 0)
        buttonBar.setWidth(32, forSegment: 1)
        buttonBar.setEnabled(false, forSegment: 2)
        view.addSubview(buttonBar)
        buttonBar.snp.makeConstraints() { make in
            make.bottom.right.equalToSuperview().offset(1)
            make.left.equalToSuperview().offset(-1)
            make.top.equalTo(scrollView.snp.bottom)
        }
    }
}
