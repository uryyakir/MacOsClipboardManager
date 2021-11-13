//
//  ClipboardTableView.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 24/09/2021.
//

import Foundation
import AppKit

extension ClipboardTableVC {
    override func keyUp(with event: NSEvent) {
        /*
         This function defines application behavior in relation to user keyboard presses.
         This includes alteration between search field and table cells, populating search field when letters are pressed etc.
         */
        if [KeyCodes.KEYUP.rawValue, KeyCodes.KEYDOWN.rawValue].contains(Int(event.keyCode)) {
            if let currentCellExtendedPopover = self.hoveredRow?.cellExtendedPopover {
                // close it even if mouse hovers the popover
                if currentCellExtendedPopover.isShown { currentCellExtendedPopover.close() }
            }
            self.initiateCellPopoverWithKeyboardNavigation()
        }
        if event.keyCode == KeyCodes.KEYUP.rawValue && self.firstRowSelected {  // if user pressed the "UP" key while the first row is selected
            // move to search field only if the first row is the only row selected
            if self.selectedRowIndexes.count == 1 && self.selectedRowIndexes.first == 0 {
                self.view.window?.makeFirstResponder(self.searchField)
            }
        } else if event.keyCode <= 50 && event.keyCode != KeyCodes.ENTER.rawValue {
            // all keyboard keys relevant for clipboard history lookup
            self.initiateClipboardSearchWithInput(characters: event.characters!)
        }
        self.firstRowSelected = (self.selectedRowIndexes == IndexSet([0]))
    }

    private func initiateCellPopoverWithKeyboardNavigation() {
        let hoveredRowIndex = self.selectedRowIndexes.first!
        self.doMouseExited()
        self.setAndInitiateHoveredRow(hoveredRowIndex: hoveredRowIndex, backgroundColorRequired: false)
    }

    private func initiateClipboardSearchWithInput(characters: String) {
        self.view.window?.makeFirstResponder(searchField)
        self.searchField!.stringValue.append(characters)
        self.searchField!.currentEditor()?.moveToEndOfLine(self)
        self.searchField!.sendAction(searchField?.action, to: searchField?.target)  // update table record filtering
    }

    private func getSelectedCells(indexSet: IndexSet) -> [ClipboardTableCell] {
        /*
         Return an array of the selected ClipboardTableCell-s.
         This is useful for cell UI actions across all selected cells.
         */
        return Array(indexSet).map { (index) -> ClipboardTableCell in
            (self.tableView.rowView(
                atRow: index, makeIfNecessary: false
            )?.view(atColumn: 0) as? ClipboardTableCell)!
        }
    }

    private func extractRowsText(filterIndices: [Int] = []) -> [ClipboardObject] {
        /*
         Given an array controller and a list of the relevant indices - extract a list of ClipboardObject-s
         */
        let relevantRows: [ClipboardObject]
        let arrangedObjects = (self.arrayController.arrangedObjects as? [ClipboardObject])!
        if filterIndices.isEmpty {
            relevantRows = arrangedObjects  // all records are requested
        } else {
            relevantRows = filterIndices.map { (int) -> ClipboardObject in
                arrangedObjects[int]
            }
        }
        return relevantRows
    }

    func getSelectedValues() -> [ClipboardObject]! {
        // fetching selected rows indices and converting it into an array
        let selectedRowIndices = (self.selectedRowIndexes.map({$0}))
        self.getSelectedCells(indexSet: selectedRowIndexes).forEach { $0.flashSelection() }  // indicate cell selection via border flashing
        return self.extractRowsText(
            filterIndices: selectedRowIndices
        )
    }

    @objc func onItemDoubleClicked() {
        ClipboardHandler.copyToClipboard(values: self.getSelectedValues()!)
    }

    func highlightFirstItem(_ sender: Any) {
        /*
         When the user moves from search field to table navigation using the down arrow-key,
         move focus back to table and highlight the first row.
         */
        let tableView = Constants.mainVC.clipboardTableVC.tableView
        self.view.window?.makeFirstResponder(tableView)
        tableView.selectRowIndexes(IndexSet([0]), byExtendingSelection: false)
    }

    private func getHoveredRowView(row: Int) -> HoveredRow {
        let rowView = self.tableView.rowView(atRow: row, makeIfNecessary: false)
        return HoveredRow(
            rowIndex: row,
            rowView: rowView
        )
    }

    private func prepareCellExtendedPopoverText() {
        /*
         On cell hover / cell selection using keyboard keys - this function is responsible
         for preparing the extended popover object, supporting HTML-formatted / plain text, and also images.
         */
        let clipboardObject = self.extractRowsText(
            filterIndices: [self.hoveredRow!.rowIndex]
        )[0]
        let cellAttributedString = clipboardObject.extractAttributedStringFromCell()
        self.cellExtendedPopoverVC!.textField!.attributedStringValue = cellAttributedString
    }

    private func cellExtendedPopoverIsVisible(cellExtendedPopover: CellExtendedPopover, hoveredRowRect: NSRect) {
        cellExtendedPopover.show(
            relativeTo: hoveredRowRect,
            of: self.tableView,
            preferredEdge: NSRectEdge.minX
        )
        self.cellExtendedPopoverVC!.scrollView.documentView!.scroll(.zero)  // scrolling document view (containing the text field) to top-left
    }

    @objc private func popoverCellExtended(sender: Timer) {
        /*
         This function is called when hover timer completes for some row.
         It prepares and shows the popover.
         */
        let cellExtendedPopover = CellExtendedPopover()
        let hoveredRowRect = self.tableView.rect(ofRow: self.hoveredRow!.rowIndex)
        // reallocate CellExtendedPopoverVC if previously deallocated
        if self.cellExtendedPopoverVC == nil { self.cellExtendedPopoverVC = CellExtendedPopoverVC.newInstance() }

        cellExtendedPopover.contentViewController = self.cellExtendedPopoverVC  // set cell popover VC
        if self.cellExtendedPopoverVC!.textField == nil {
            self.cellExtendedPopoverVC!.initView()  // on first run, init VC so the textField attribute is available
        }
        self.prepareCellExtendedPopoverText()
        self.cellExtendedPopoverIsVisible(cellExtendedPopover: cellExtendedPopover, hoveredRowRect: hoveredRowRect)
        // store extended popover instance for future usage
        self.hoveredRow?.cellExtendedPopover = cellExtendedPopover
        sender.invalidate()
    }

    private func setHoveredCellBackgroundColor(rowView: NSTableRowView) {
        rowView.backgroundColor = TableViewConstants.cellHoverBackgroundColor
    }

    private func setHoveredCellBehavior(backgroundColorRequired: Bool = true, rowView: NSTableRowView? = nil) -> Timer {
        /*
         Add background color and initiate cell popover countdown
         */
        if backgroundColorRequired { self.setHoveredCellBackgroundColor(rowView: rowView ?? self.hoveredRow!.rowView!) }
        return Timer.scheduledTimer(
            timeInterval: TableViewConstants.timeBeforeHoverPopover,
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
        self.hoveredRow?.rowView?.backgroundColor = Constants.NSViewsBackgroundColor  // remove color from previously hovered row
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
            if timerStopIteration > TableViewConstants.timeBeforeExtendedPopoverClose + 0.1 {
                // enough time passed so that a previously open popover should've closed by now (unless user hovers it)
                if cellExtendedPopover!.isShown && self.hoveredRowsWhilePopoverOpen.isEmpty {
                    // assuming user moved cursor to open popover - noop
                    currentOtherHoveredRow.rowView!.backgroundColor = Constants.NSViewsBackgroundColor
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
                        self.hoveredRow?.rowView?.backgroundColor = Constants.NSViewsBackgroundColor  // reset background color
                        self.hoveredRow = hoveredRow  // set currently hovered row as self.hoveredRow
                        completion()
                        timer.invalidate()
                    }
                }
            }
            timerStopIteration += 0.1
        })
    }

    private func doMouseEntered(event: NSEvent, hoveredRowIndex: Int) {
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
            // user probably moved mouse outside row view and then re-hovered the same row
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
        let hoveredRowIndex = (event.trackingArea?.userInfo![TableViewConstants.cellTrackingDataKey] as? Int)!
        self.doMouseEntered(event: event, hoveredRowIndex: hoveredRowIndex)
    }

    private func doMouseExited() {
        if !self.hoveredRowsWhilePopoverOpen.isEmpty {
            // remove and invalidate oldest hoveredRow
            let hoveredRow = self.hoveredRowsWhilePopoverOpen.removeFirst()
            hoveredRow.hoverTimer!.invalidate()
            hoveredRow.rowView?.backgroundColor = Constants.NSViewsBackgroundColor
        } else {
            // "normal" behavior - user exited some row and moved to another
            // without doing so while a popover was open
            self.hoveredRow?.rowView?.backgroundColor = Constants.NSViewsBackgroundColor
            if let cellExtendedPopover = self.hoveredRow?.cellExtendedPopover {
                // schedule a timer until previously open popover is closed
                Timer.scheduledTimer(withTimeInterval: TableViewConstants.timeBeforeExtendedPopoverClose, repeats: false, block: { _ in
                    // close popover if user isn't examining it after timer is complete
                    if !cellExtendedPopover.userExaminesExtendedPopover {
                        cellExtendedPopover.close()
                    }
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
