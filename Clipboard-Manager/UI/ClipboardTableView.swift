//
//  ClipboardTableView.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 24/09/2021.
//

import Foundation
import AppKit

class ClipboardMenu: NSMenu {
    override init(title: String) {
        super.init(title: title)
        setupClipboardMenu()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupClipboardMenu() {
        let menuItem1 = MenuItem(title: "Slider:")
        self.addItem(menuItem1)

        let menuItem2 = MenuItem(title: "Slider 1")
        self.addItem(menuItem2)

        self.addItem(NSMenuItem.separator())

        self.addItem(NSMenuItem(title: "Quit", action: nil, keyEquivalent: "q"))
    }
}

class MenuItem: NSMenuItem {
    override init(title: String, action: Selector? = nil, keyEquivalent: String = "") {
        let actionOverwrite = (action == nil) ? #selector(doNothing) : action
        super.init(title: title, action: actionOverwrite, keyEquivalent: keyEquivalent)
        self.target = self
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc private func doNothing() {
        print("hello hello world!")
    }
}
