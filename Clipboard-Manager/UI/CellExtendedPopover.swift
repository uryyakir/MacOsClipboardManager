//
//  CellExtendedPopover.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 16/10/2021.
//

import Foundation
import Cocoa

class CellExtendedPopover: NSPopover, NSPopoverDelegate {
    var userExaminesExtendedPopover: Bool = false

    override init() {
        super.init()
        self.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func popoverDidClose(_ notification: Notification) {
        // removing reference to cellExtendedPopoverVC to dealloc memory
        Constants.mainVC.clipboardTableVC.cellExtendedPopoverVC = nil
    }
}
