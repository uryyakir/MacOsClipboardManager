//
//  ClipboardSearchField.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 28/09/2021.
//

import Foundation
import Cocoa

class ClipboardSearchField: NSSearchField {
    override init(frame: NSRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func becomeFirstResponder() -> Bool {
        Constants.mainVC.clipboardTableVC.hoveredRow?.hoverTimer?.invalidate()  // if an existing timer is in progress for the first row - invalidate that
        guard super.becomeFirstResponder() else {
            return false
        }
        return true
    }
}
