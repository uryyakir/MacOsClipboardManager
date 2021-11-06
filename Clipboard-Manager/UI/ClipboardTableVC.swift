//
//  ClipboardTableView.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 24/09/2021.
//

import Foundation
import AppKit

class ClipboardTableVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    let scrollView = NSScrollView()
    let tableView = NSTableView()
    let arrayController: NSArrayController = NSArrayController()
    var firstRowSelected: Bool = false
    let clipboardHistory: [ClipboardCopiedObject] = Constants.dbHandler.grabAllClipboardHistory()
    var hoveredRow: HoveredRow?
    let cellExtendedPopoverVC = CellExtendedPopoverVC.newInstance()
    var hoveredRowsWhilePopoverOpen: [HoveredRow] = []

    override func loadView() {
        self.view = NSView()
        // setup functions
        AppDelegate.setupScrollView(parentView: self.view, scrollView: self.scrollView, topConstant: 23)
        self.scrollView.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(
            // observe table view scrolling so existing timers / popovers are invalidated or closed accordingly
            self,
            selector: #selector(contentViewDidChangeBounds),
            name: NSView.boundsDidChangeNotification,
            object: self.scrollView.contentView
        )

        setupTableView()
        bindSearchField()
    }

    override func viewDidLayout() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        // only bind tableView to arrayController AFTER loadView function is run and tableView was setup
        // otherwise, the UI changes caused by the bind will re-invoke viewDidLayout causing multiple binds and UI bugs
        self.tableView.bind(.content, to: self.arrayController, withKeyPath: "arrangedObjects", options: nil)
    }

    @objc private func contentViewDidChangeBounds(_ notification: NSNotification) {
        if let hoveredRow = self.hoveredRow {
            self.hoveredRow?.rowView?.backgroundColor = NSColor.clear
            self.hoveredRow?.hoverTimer?.invalidate()
            if let extendedCellPopover = hoveredRow.cellExtendedPopover {
                extendedCellPopover.close()
            }
        }
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
        // populate table rows
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
            options: [.predicateFormat: "rawClipboardString CONTAINS[cd] $value"]
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
        if [KeyCodes.KEYUP, KeyCodes.KEYDOWN].contains(Int(event.keyCode)) {
            let hoveredRowIndex = Constants.appDelegate.clipboardTableVC.tableView.selectedRowIndexes.first!
            self.doMouseExited()
            self.setAndInitiateHoveredRow(hoveredRowIndex: hoveredRowIndex, backgroundColorRequired: false)
            super.keyDown(with: event)
        }
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

    static func extractRowsText(tableArrayController: NSArrayController, filterIndices: [Int] = []) -> [ClipboardObject] {
        let relevantRows: [ClipboardObject]
        let arrangedObjects = (tableArrayController.arrangedObjects as? [ClipboardObject])!
        // translating indices to strings (by extracting clipboardString from the underlying ClipboardObject objects)
        if filterIndices.isEmpty {
            relevantRows = arrangedObjects
        } else {
            relevantRows = filterIndices.map { (int) -> ClipboardObject in
                arrangedObjects[int]
            }
        }
        return relevantRows
    }

    func getSelectedValues() -> [ClipboardObject]! {
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

    private func prepareCellExtendedPopoverText() {
        let clipboardObject = ClipboardTableVC.extractRowsText(
            tableArrayController: self.arrayController,
            filterIndices: [self.hoveredRow!.rowIndex]
        )[0]
        let cellAttributedString = (clipboardObject.HTMLClipboardString ?? clipboardObject.rawClipboardString)!.htmlToAttributedString(
            resizeToWidth: CellExtendedPopoverVC.newInstance().view.bounds.width,
            resizeToHeight: nil
        )!
        ClipboardObject.colorAttributedString(string: cellAttributedString, color: Constants.textDefaultColor)
        self.cellExtendedPopoverVC.textField!.attributedStringValue = cellAttributedString
    }

    private func cellExtendedPopoverIsVisible(cellExtendedPopover: CellExtendedPopover, hoveredRowRect: NSRect) {
        cellExtendedPopover.show(
            relativeTo: hoveredRowRect,
            of: self.tableView,
            preferredEdge: NSRectEdge.minX
        )
        self.cellExtendedPopoverVC.scrollView.documentView!.scroll(.zero)  // scrolling document view (containing the text field) to top-left
    }

    @objc private func popoverCellExtended(sender: Timer) {
        let cellExtendedPopover = CellExtendedPopover()
        let hoveredRowRect = self.tableView.rect(ofRow: self.hoveredRow!.rowIndex)

        cellExtendedPopover.contentViewController = self.cellExtendedPopoverVC  // set cell popover VC
        if self.cellExtendedPopoverVC.textField == nil {
            self.cellExtendedPopoverVC.initView()  // on first run, init VC so the textField attribute is available
        }
        self.prepareCellExtendedPopoverText()
        self.cellExtendedPopoverIsVisible(cellExtendedPopover: cellExtendedPopover, hoveredRowRect: hoveredRowRect)
        // store extended popover instance for future usage
        self.hoveredRow?.cellExtendedPopover = cellExtendedPopover
        sender.invalidate()
    }

    private func setHoveredCellBackgroundColor(rowView: NSTableRowView) {
        rowView.backgroundColor = Constants.cellHoverBackgroundColor
    }

    private func setHoveredCellBehavior(backgroundColorRequired: Bool = true, rowView: NSTableRowView? = nil) -> Timer {
        if backgroundColorRequired { self.setHoveredCellBackgroundColor(rowView: rowView ?? self.hoveredRow!.rowView!) }
        return Timer.scheduledTimer(
            timeInterval: Constants.timeBeforeHoverPopover,
            target: self,
            selector: #selector(self.popoverCellExtended),
            userInfo: nil,
            repeats: true
        )
    }

    private func setAndInitiateHoveredRow(hoveredRowIndex: Int, backgroundColorRequired: Bool = true) {
        self.hoveredRow = self.getHoveredRowView(
            row: hoveredRowIndex
        )
        self.hoveredRow!.hoverTimer = self.setHoveredCellBehavior(backgroundColorRequired: backgroundColorRequired)
    }

    private func handleRowHoverWhileOtherRowPopoverIsOpen(currentOtherHoveredRow: HoveredRow) {
        self.hoveredRow?.rowView?.backgroundColor = .clear  // remove color from previously hovered row
        // initiate popover sequence on newly hovered row
        currentOtherHoveredRow.hoverTimer = self.setHoveredCellBehavior(rowView: currentOtherHoveredRow.rowView!)
        self.hoveredRowsWhilePopoverOpen.append(currentOtherHoveredRow)

        self.awaitCellPopoverClosure(currentOtherHoveredRow: currentOtherHoveredRow) {
            if self.hoveredRowsWhilePopoverOpen.isEmpty && !self.hoveredRow!.hoverTimer!.isValid {
                let cellExtendedPopover = self.hoveredRow?.cellExtendedPopover
                if cellExtendedPopover == nil || !cellExtendedPopover!.isShown {
                    // we get here if there's no other rows in hoveredRowsWhilePopoverOpen but there's no other timer currently initiated
                    // check that user is actually hovering some row
                    // it doesn't really matter which one because the latest one is automatically stored in self.hoveredRow
                    if (self.tableView.row(at: self.view.window!.mouseLocationOutsideOfEventStream)) > 0 {
                        self.hoveredRow?.hoverTimer = self.setHoveredCellBehavior()
                    }
                }
            }
        }
    }

    private func awaitCellPopoverClosure(currentOtherHoveredRow: HoveredRow, completion:@escaping () -> Void) {
        /*
         This function is responsible for handling UI activity while some cell popover is open.
         Within that time period, it is possible for the user to hover other rows, exit the tableView and return to the popover.
         The UI logic for all those UCs is implemented here.
        */
        var timerStopIteration = 0.0
        let cellExtendedPopover = self.hoveredRow?.cellExtendedPopover

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            // iterate every 0.1 sec and check current status
            if timerStopIteration > Constants.timeBeforeExtendedPopoverClose + 0.1 {
                // enough time passed so that a previously open popover should've closed by now (unless user hovers it)
                if cellExtendedPopover!.isShown && self.hoveredRowsWhilePopoverOpen.isEmpty {
                    // assuming user moved cursor to open popover - noop
                    currentOtherHoveredRow.rowView!.backgroundColor = .clear
                    completion()
                    timer.invalidate()
                } else if !self.hoveredRowsWhilePopoverOpen.isEmpty {
                    completion()
                    timer.invalidate()
                }
            }
            // checking the following stop-conditions in each iteration
            if !cellExtendedPopover!.isShown {
                completion()
                timer.invalidate()
            } else {
                if let hoveredRow = self.hoveredRowsWhilePopoverOpen.popLast() {
                    // another row was hovered while a popover is open
                    DispatchQueue.main.async {
                        cellExtendedPopover!.close()  // close open popover
                        self.hoveredRow?.rowView?.backgroundColor = .clear  // reset background color
                        self.hoveredRow = hoveredRow  // set currently hovered row as self.hoveredRow
                        completion()
                        timer.invalidate()
                    }
                }
            }
            timerStopIteration += 0.1
        })
    }

    func doMouseEntered(event: NSEvent, hoveredRowIndex: Int) {
        if self.hoveredRow == nil {
            // set hovered row, alter background color and set popover timer
            self.setAndInitiateHoveredRow(hoveredRowIndex: hoveredRowIndex)
            return
        }
        // the hoveredRow attribute was previously set
        let currentOtherHoveredRow = self.getHoveredRowView(  // getting instance of currently hovered row
            row: hoveredRowIndex
        )
        if currentOtherHoveredRow.rowIndex == self.hoveredRow?.rowIndex {
            // user probably moved mouse outside table view and then re-hovered the same row
            // no need to overwrite the hoveredRow attribute
            self.hoveredRow!.hoverTimer = self.setHoveredCellBehavior()
            return
        }
        // user hovers different row than the previous ones
        if let previousCellExtendedPopover = self.hoveredRow?.cellExtendedPopover {
            if previousCellExtendedPopover.isShown {
                // previous row's extended popover is still shown
                handleRowHoverWhileOtherRowPopoverIsOpen(currentOtherHoveredRow: currentOtherHoveredRow)
                return
            }
        }
        // if previously hovered row did not have a popover / it is not longer shown
        self.setAndInitiateHoveredRow(hoveredRowIndex: hoveredRowIndex)
    }

    override func mouseEntered(with event: NSEvent) {
        let hoveredRowIndex = (event.trackingArea?.userInfo!["row"] as? Int)!
        self.doMouseEntered(event: event, hoveredRowIndex: hoveredRowIndex)
    }

    private func doMouseExited() {
        if !self.hoveredRowsWhilePopoverOpen.isEmpty {
            // remove and invalidate oldest hoveredRow
            let hoveredRow = self.hoveredRowsWhilePopoverOpen.removeFirst()
            hoveredRow.hoverTimer!.invalidate()
            hoveredRow.rowView?.backgroundColor = .clear
        } else {
            // "normal" behavior - user exited some row and moved to another
            // without doing so while a popover was open
            self.hoveredRow?.rowView!.backgroundColor = .clear
            if let cellExtendedPopover = self.hoveredRow?.cellExtendedPopover {
                // schedule a timer until previously open popover is closed
                Timer.scheduledTimer(withTimeInterval: Constants.timeBeforeExtendedPopoverClose, repeats: false, block: { _ in
                    // close popover if user isn't examining it after timer is complete
                    if !cellExtendedPopover.userExaminesExtendedPopover { cellExtendedPopover.close() }
                })
            }
        }
        // always invalidate existing hovered row timer when it is exited
        self.hoveredRow?.hoverTimer!.invalidate()
    }

    override func mouseExited(with event: NSEvent) {
        self.doMouseExited()
    }
}
