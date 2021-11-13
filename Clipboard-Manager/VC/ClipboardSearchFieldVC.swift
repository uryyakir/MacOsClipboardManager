//
//  ClipboardSearchFieldVC.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 14/11/2021.
//

import Foundation
import Cocoa

class ClipboardSearchFieldVC: NSViewController, NSSearchFieldDelegate {
    override func loadView() {
        let clipboardSearchField = ClipboardSearchField()
        clipboardSearchField.delegate = self
        self.view = clipboardSearchField
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(moveDown(_:)) {
            Constants.mainVC.clipboardTableVC.highlightFirstItem(self.view)
            return true
        } else if commandSelector == #selector(cancelOperation(_:)) {
            _ = Constants.mainVC.closeCellExtendedPopoverIfOpen()
            if (self.view as? ClipboardSearchField)!.stringValue == "" {
                Constants.appDelegate.closePopover(sender: self)
            }
        }
        return false
    }
}
