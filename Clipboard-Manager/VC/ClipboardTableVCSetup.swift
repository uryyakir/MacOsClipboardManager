//
//  ClipboardTableVCSetup.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 06/11/2021.
//

import Foundation
import Cocoa

class ClipboardTableVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    let scrollView = NSScrollView()
    let tableView = NSTableView()
    var searchField: NSSearchField?
    let arrayController: NSArrayController = NSArrayController()
    var firstRowSelected: Bool = false
    let clipboardHistory: [ClipboardCopiedObject] = Constants.dbHandler.grabAllClipboardHistory()
    var hoveredRow: HoveredRow?
    var cellExtendedPopoverVC: CellExtendedPopoverVC? = CellExtendedPopoverVC.newInstance()
    var hoveredRowsWhilePopoverOpen: [HoveredRow] = []
    var selectedRowIndexes: IndexSet {
        return self.tableView.selectedRowIndexes
    }

    override func loadView() {
        self.view = NSView()
        // get search field reference after AppDelegate has finished initialization
        self.searchField = (Constants.mainVC.clipboardSearchFieldVC.view as? NSSearchField)!
        // setup functions
        AppDelegate.setupScrollView(parentView: self.view, scrollView: self.scrollView, topConstant: 23)
        self.setupTableView()
        self.populateTableView()
        self.bindSearchField()
        self.listenForScrollViewScrolling()
    }

    override func viewDidLayout() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        // only bind tableView to arrayController AFTER loadView function has run and tableView was setup
        // otherwise, the UI changes caused by the bind will re-invoke viewDidLayout causing multiple binds and UI bugs
        self.tableView.bind(.content, to: self.arrayController, withKeyPath: "arrangedObjects", options: nil)
    }

    private func setupTableView() {
        // table setup
        tableView.frame = scrollView.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.backgroundColor = Constants.NSViewsBackgroundColor
        tableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        tableView.allowsMultipleSelection = true
        tableView.doubleAction = #selector(onItemDoubleClicked)
        tableView.intercellSpacing = NSSize(width: 0, height: 10)
        // setup table column
        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: Constants.tableViewColumnName))
        tableView.addTableColumn(col)
        // setup table scroll view
        scrollView.documentView = tableView
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = true
    }

    private func populateTableView() {
        // populate table rows
        for val in self.clipboardHistory {
            self.arrayController.addObject(ClipboardObject(val))
        }
    }

    private func bindSearchField() {
        self.searchField!.bind(
            .predicate,
            to: self.arrayController,
            withKeyPath: NSBindingName.filterPredicate.rawValue,
            options: [.predicateFormat: "\(Constants.predicateMatchClipboardObjectAttribute) CONTAINS[\(Constants.predicateOptions)] $value"]
        )
    }

    private func listenForScrollViewScrolling() {
        self.scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(
            // observe table view scrolling so existing timers / popovers are invalidated or closed accordingly
            self,
            selector: #selector(contentViewDidChangeBounds),
            name: NSView.boundsDidChangeNotification,
            object: self.scrollView.contentView
        )
    }

    @objc private func contentViewDidChangeBounds(_ notification: NSNotification) {
        if let hoveredRow = self.hoveredRow {
            self.hoveredRow?.rowView?.backgroundColor = Constants.NSViewsBackgroundColor
            self.hoveredRow?.hoverTimer?.invalidate()
            if let extendedCellPopover = hoveredRow.cellExtendedPopover {
                extendedCellPopover.close()
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.clipboardHistory.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let clipboardTableCell = ClipboardTableCell(frame: NSRect())
        clipboardTableCell.addTrackingArea(
            // add tracking inside the scrollView (to later support hover-detection)
            NSTrackingArea(
                rect: clipboardTableCell.frame,
                options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited],
                owner: self,
                userInfo: [Constants.cellTrackingDataKey: row]
            )
        )
        if tableColumn?.identifier.rawValue == Constants.tableViewColumnName {
            clipboardTableCell.textField!.bind(
                .value,
                to: clipboardTableCell,
                withKeyPath: "objectValue.\(Constants.cellTextFieldClipboardObjectAttribute)",
                options: nil
            )
        }
        return clipboardTableCell
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView()
        return rowView
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
}
