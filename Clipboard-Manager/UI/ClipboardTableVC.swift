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
    static var filteredIndices: [Int] = []
    static var unhiddenIndices: [Int] = []
    let arrayController: NSArrayController = NSArrayController()

    override func loadView() {
        self.view = NSView()
        setupScrollView()
        setupTableView()
    }

    override func viewDidLayout() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        // only bind tableView to arrayController AFTER loadView function is run and tableView was setup
        // otherwise, the UI changes caused by the bind will re-envoke viewDidLayout causing multiple binds and UI bugs
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

//      print("total objects \(Constants.clipboardTestValues.count)")
        for val in Constants.clipboardTestValues {
            self.arrayController.addObject(Dummy(val))
        }

        // TODO: make sure to update this array when copying additional data (more efficient than reading entire DB again)
//        ClipboardTableVC.allClipboardHistory = self.tableView.subviews  // store a semi-static array of all initial subviews
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
//        return 100
        return Constants.clipboardTestValues.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        let clipboardTableCell = ClipboardTableCell(frame: NSRect(), stringValue: Constants.clipboardTestValues[row])
        print((self.arrayController.arrangedObjects as? [Dummy])!.count)
        let clipboardTableCell = ClipboardTableCell(frame: NSRect())
        if tableColumn?.identifier.rawValue == "col" {
            print("here")
            clipboardTableCell.textField!.bind(.value, to: clipboardTableCell, withKeyPath: "objectValue.col", options: nil)
        }
        return clipboardTableCell
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView()
        return rowView
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
        return relevantCells.map { $0.stringValue! }  // extracting text from TableCells, returning an array of all selected strings
    }

    func getSelectedValues() -> [String]! {
        // fetching selected rows indices and converting it into an array
        let selectedRowIndices = (Constants.appDelegate.clipboardTableVC.tableView.selectedRowIndexes.map({$0}))
        return ClipboardTableVC.extractRowsText(tableView: Constants.appDelegate.clipboardTableVC.tableView, filterIndices: selectedRowIndices)
    }

    static func filterClipboardCells(textFilter: String) {

//        ClipboardTableVC.filteredIndices = []
//        ClipboardTableVC.unhiddenIndices = []
//        // filtering all relevant rows from the allSubviews array
//        for subview in Constants.appDelegate.clipboardTableVC.tableView.subviews {
//            let actualIndex = Constants.appDelegate.clipboardTableVC.tableView.row(for: subview)
//            if !(
//                (
//                    (
//                        (subview as? NSTableRowView)?.view(atColumn: 0)
//                    ) as? ClipboardTableCell
//            )?.stringValue?.lowercased().contains(textFilter.lowercased()) ?? false) {
//                if !subview.isHidden {
//                    ClipboardTableVC.filteredIndices.append(actualIndex)
//                }
//            }
//        }
//        print("hiding: ", ClipboardTableVC.filteredIndices)
//        Constants.appDelegate.clipboardTableVC.tableView.hideRows(at: IndexSet(ClipboardTableVC.filteredIndices), withAnimation: .effectFade)
//
//        print("hidden: ", Constants.appDelegate.clipboardTableVC.tableView.hiddenRowIndexes)
//        for hiddenSubviewIndex in Constants.appDelegate.clipboardTableVC.tableView.hiddenRowIndexes.map({$0}) {
//            guard let hiddenRow = Constants.appDelegate.clipboardTableVC.tableView.rowView(
//                atRow: hiddenSubviewIndex,
//                makeIfNecessary: true
//            ) else {
//                continue
//            }
//            // swiftlint:disable force_cast
//            let hiddenCell = hiddenRow.view(atColumn: 0) as! ClipboardTableCell
//            if (hiddenCell.stringValue?.lowercased().contains(textFilter.lowercased()) ?? false) || (textFilter == "") {
//                ClipboardTableVC.unhiddenIndices.append(hiddenSubviewIndex)
//            }
//        }
//        Constants.appDelegate.clipboardTableVC.tableView.beginUpdates()
//        Constants.appDelegate.clipboardTableVC.tableView.unhideRows(at: IndexSet(ClipboardTableVC.unhiddenIndices), withAnimation: .effectFade)
//        Constants.appDelegate.clipboardTableVC.tableView.endUpdates()
    }

    @objc private func onItemClicked() {
        ClipboardHandler.copyToClipboard(values: self.getSelectedValues()!)
    }
}
