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
        self.view = ClipboardSearchField()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
    }
}
