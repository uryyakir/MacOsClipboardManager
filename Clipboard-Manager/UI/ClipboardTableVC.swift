//
//  ClipboardTableView.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 24/09/2021.
//

import Foundation
import AppKit


class Dummy: NSObject {
    @objc dynamic var col: String

    init(_ col: String) {
        self.col = col
    }
}

class ClipboardTableVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    let scrollView = NSScrollView()
    let tableView = NSTableView()
    let arrayController: NSArrayController = NSArrayController()
    var firstRowSelected: Bool = false

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
        scrollView.backgroundColor = NSColor.clear
        scrollView.drawsBackground = false
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

        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col"))
        tableView.addTableColumn(col)

        scrollView.documentView = tableView
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = true

        for val in Constants.dbHandler.grabAllClipboardHistory() {
            self.arrayController.addObject(Dummy(val))
        }
    }

    private func bindSearchField() {
        let searchField = (Constants.appDelegate.clipboardSearchFieldVC.view as? NSSearchField)!
        searchField.bind(
            .predicate,
            to: self.arrayController,
            withKeyPath: NSBindingName.filterPredicate.rawValue,
            options: [.predicateFormat: "col CONTAINS[cd] $value"]
        )
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return Constants.clipboardTestValues.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let clipboardTableCell = ClipboardTableCell(frame: NSRect())
        if tableColumn?.identifier.rawValue == "col" {
            clipboardTableCell.textField!.bind(.value, to: clipboardTableCell, withKeyPath: "objectValue.col", options: nil)
        }
        return clipboardTableCell
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView()
        return rowView
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

    static func extractRowsText(tableView: NSTableView, filterIndices: [Int] = []) -> [String] {
        // swiftlint:disable force_cast
        let relevantRows: [NSTableRowView]
        // translating indices to table rowViews by filtering the table's subviews
        if filterIndices.isEmpty {
            relevantRows = (tableView.subviews as! [NSTableRowView])
        } else {
            relevantRows = filterIndices.map { (int) -> NSTableRowView in
                (tableView.subviews[int] as! NSTableRowView)
            }
        }
        let relevantCells = (relevantRows.map { ($0.view(atColumn: 0)) as! ClipboardTableCell })  // translating rows to TableCells
        // swiftlint:enable force_cast
        return relevantCells.map { $0.textField!.stringValue }  // extracting text from TableCells, returning an array of all selected strings
    }

    func getSelectedValues() -> [String]! {
        // fetching selected rows indices and converting it into an array
        let selectedRowIndices = (Constants.appDelegate.clipboardTableVC.tableView.selectedRowIndexes.map({$0}))
        return ClipboardTableVC.extractRowsText(tableView: Constants.appDelegate.clipboardTableVC.tableView, filterIndices: selectedRowIndices)
    }

    @objc private func onItemClicked() {
        ClipboardHandler.copyToClipboard(values: self.getSelectedValues()!)
    }

    func highlightFirstItem(_ sender: Any) {
        let tableView = Constants.appDelegate.clipboardTableVC.tableView
        self.view.window?.makeFirstResponder(tableView)
        tableView.selectRowIndexes(IndexSet([0]), byExtendingSelection: false)
    }
}
