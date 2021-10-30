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
}

class ClipboardSearchFieldVC: NSViewController, NSSearchFieldDelegate {
    override func loadView() {
        let clipboardSearchField = ClipboardSearchField()
        clipboardSearchField.delegate = self
        self.view = clipboardSearchField
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(moveDown(_:)) {
            Constants.appDelegate.clipboardTableVC.highlightFirstItem(self.view)
            return true
        } else if commandSelector == #selector(cancelOperation(_:)) {
            _ = MainViewController.closeCellExtendedPopoverIfOpen()
            if (self.view as? ClipboardSearchField)!.stringValue == "" {
                Constants.appDelegate.closePopover(sender: self)
            }
        }
        return false
    }
}
