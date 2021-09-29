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

    func controlTextDidChange(_ obj: Notification) {
        guard let searchField = (obj.object! as? NSSearchField) else { return }
        ClipboardTableVC.filterClipboardCells(textFilter: searchField.stringValue)
    }
}
