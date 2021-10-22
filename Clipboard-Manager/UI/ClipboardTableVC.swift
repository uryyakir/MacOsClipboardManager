//
//  ClipboardTableView.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 24/09/2021.
//

import Foundation
import AppKit

class ClipboardObject: NSObject {
    @objc dynamic var clipboardString: String
    @objc dynamic var clipboardAttributedString: NSMutableAttributedString

    init(_ clipboardStringVal: String) {
        self.clipboardString = clipboardStringVal
        self.clipboardAttributedString = clipboardStringVal.htmlToAttributedString!
        self.clipboardAttributedString.addAttribute(
            .foregroundColor,
            value: NSColor(deviceRed: 8/255, green: 165/255, blue: 218/255, alpha: 1),
            range: NSRange(location: 0, length: self.clipboardAttributedString.length)
        )
    }
}

struct HoveredRow {
    let rowIndex: Int
    let rowView: NSTableRowView?

    init(rowIndex: Int, rowView: NSTableRowView?) {
        self.rowIndex = rowIndex
        self.rowView = rowView
    }
}

class ClipboardTableVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    let scrollView = NSScrollView()
    let tableView = NSTableView()
    let arrayController: NSArrayController = NSArrayController()
    var firstRowSelected: Bool = false
    let clipboardHistory: [String] = Constants.dbHandler.grabAllClipboardHistory()
    var hoveredRow: HoveredRow?
    var hoverTimer: Timer?
    let cellExtendedPopoverVC = CellExtendedPopoverVC.newInstance()

    override func loadView() {
        self.view = NSView()
        // setup functions
        setupScrollView()
        setupTableView()
        bindSearchField()
    }

    override func viewDidLayout() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        // only bind tableView to arrayController AFTER loadView function is run and tableView was setup
        // otherwise, the UI changes caused by the bind will re-invoke viewDidLayout causing multiple binds and UI bugs
        self.tableView.bind(.content, to: self.arrayController, withKeyPath: "arrangedObjects", options: nil)
    }

    private func setupScrollView() {
        self.view.addSubview(scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.backgroundColor = NSColor.clear
        self.scrollView.drawsBackground = false
        self.view.addConstraints([
            NSLayoutConstraint(
                item: self.scrollView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0
            ),
            NSLayoutConstraint(
                item: self.scrollView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 23
            ),
            NSLayoutConstraint(
                item: self.scrollView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0
            ),
            NSLayoutConstraint(
                item: self.scrollView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0
            )
        ])
    }

    private func setupTableView() {
        tableView.frame = scrollView.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.backgroundColor = NSColor.clear
        tableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
        tableView.allowsMultipleSelection = true
        tableView.doubleAction = #selector(onItemClicked)
        tableView.intercellSpacing = NSSize(width: 0, height: 10)

        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col"))
        tableView.addTableColumn(col)

        scrollView.documentView = tableView
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = true

        for val in self.clipboardHistory {
            self.arrayController.addObject(ClipboardObject(val))
        }
    }

    private func bindSearchField() {
        let searchField = (Constants.appDelegate.clipboardSearchFieldVC.view as? NSSearchField)!
        searchField.bind(
            .predicate,
            to: self.arrayController,
            withKeyPath: NSBindingName.filterPredicate.rawValue,
            options: [.predicateFormat: "clipboardString CONTAINS[cd] $value"]
        )
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
                userInfo: ["row": row]
            )
        )
        if tableColumn?.identifier.rawValue == "col" {
            clipboardTableCell.textField!.bind(
                .value,
                to: clipboardTableCell,
                withKeyPath: "objectValue.clipboardAttributedString",
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

    override func keyUp(with event: NSEvent) {
        let searchField = (Constants.appDelegate.clipboardSearchFieldVC.view as? NSSearchField)
        let selectedIndices = Constants.appDelegate.clipboardTableVC.tableView.selectedRowIndexes
        if event.keyCode == KeyCodes.KEYUP && self.firstRowSelected {  // if user pressed the "UP" key while the first row is selected
            if selectedIndices.count == 1 && selectedIndices.first == 0 {  // move to search field only if the first row is the only row selected
                self.view.window?.makeFirstResponder(Constants.appDelegate.clipboardSearchFieldVC.view)
            }
        } else if event.keyCode <= 50 && event.keyCode != KeyCodes.ENTER {  // all keyboard keys relevant for clipboard history lookup
            self.view.window?.makeFirstResponder(searchField)
            searchField?.stringValue.append(event.characters!)
            searchField?.currentEditor()?.moveToEndOfLine(self)
            searchField?.sendAction(searchField?.action, to: searchField?.target)  // update table record filtering
        }
        self.firstRowSelected = (selectedIndices == IndexSet([0]))
    }

    static func extractRowsText(tableArrayController: NSArrayController, filterIndices: [Int] = []) -> [String] {
        let relevantRows: [String]
        let arrangedObjects = (tableArrayController.arrangedObjects as? [ClipboardObject])!
        // translating indices to strings (by extracting clipboardString from the underlying ClipboardObject objects)
        if filterIndices.isEmpty {
            relevantRows = arrangedObjects.map { (clipboardObject) -> String in
                clipboardObject.clipboardString
            }
        } else {
            relevantRows = filterIndices.map { (int) -> String in
                arrangedObjects[int].clipboardString
            }
        }
        return relevantRows
    }

    func getSelectedValues() -> [String]! {
        // fetching selected rows indices and converting it into an array
        let selectedRowIndices = (Constants.appDelegate.clipboardTableVC.tableView.selectedRowIndexes.map({$0}))
        return ClipboardTableVC.extractRowsText(
            tableArrayController: Constants.appDelegate.clipboardTableVC.arrayController,
            filterIndices: selectedRowIndices
        )
    }

    @objc private func onItemClicked() {
        ClipboardHandler.copyToClipboard(values: self.getSelectedValues()!)
    }

    func highlightFirstItem(_ sender: Any) {
        let tableView = Constants.appDelegate.clipboardTableVC.tableView
        self.view.window?.makeFirstResponder(tableView)
        tableView.selectRowIndexes(IndexSet([0]), byExtendingSelection: false)
    }

    private func getHoveredRowView(row: Int) -> HoveredRow {
        let rowView = tableView.rowView(atRow: row, makeIfNecessary: false)
        return HoveredRow(
            rowIndex: row,
            rowView: rowView
        )
    }

    @objc private func checkRowStillHovered(sender: Timer) {
        let cellExtendedPopover = CellExtendedPopover()
        let hoveredRowRect = self.tableView.rect(ofRow: self.hoveredRow!.rowIndex)

        cellExtendedPopover.contentViewController = self.cellExtendedPopoverVC  // set cell popover VC
        cellExtendedPopover.show(
            relativeTo: hoveredRowRect,
            of: self.tableView,
            preferredEdge: NSRectEdge.minX
        )
        sender.invalidate()
    }

    override func mouseEntered(with event: NSEvent) {
        // TODO: convert to ENUM with attributes calculating everything?
        self.hoveredRow = self.getHoveredRowView(
            row: (event.trackingArea?.userInfo!["row"] as? Int)!
        )
        self.hoveredRow?.rowView!.backgroundColor = NSColor(deviceRed: 135/255, green: 206/255, blue: 250/255, alpha: 0.3)
        self.hoverTimer = Timer.scheduledTimer(
            timeInterval: Constants.timeBeforeHoverPopover,
            target: self,
            selector: #selector(self.checkRowStillHovered),
            userInfo: nil,
            repeats: true
        )
    }

    override func mouseExited(with event: NSEvent) {
        self.hoveredRow?.rowView!.backgroundColor = .clear
        // invalidate existing hovered row timer
        self.hoverTimer!.invalidate()
    }
}
