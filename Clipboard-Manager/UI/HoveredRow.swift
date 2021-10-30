//
//  HoveredRow.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 31/10/2021.
//

import Foundation
import Cocoa

class HoveredRow {
    let rowIndex: Int
    let rowView: NSTableRowView?
    var cellExtendedPopover: CellExtendedPopover?
    var hoverTimer: Timer?

    init(rowIndex: Int, rowView: NSTableRowView?) {
        self.rowIndex = rowIndex
        self.rowView = rowView
    }
}
