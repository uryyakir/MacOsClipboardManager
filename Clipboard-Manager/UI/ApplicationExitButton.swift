//
//  ApplicationExitButton.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 18/11/2021.
//

import Foundation
import Cocoa

class ApplicationExitButton: NSButton {
    override init(frame: NSRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.wantsLayer = true
        self.layer?.cornerRadius = 5
        self.layer?.borderWidth = 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupMinimizeButton() {
        self.backgroundColor = .red
        self.title = "X"
        self.action = #selector(Constants.appDelegate.closePopover)
    }

    func setupExitButton() {
        self.backgroundColor = NSColor(deviceRed: 16/256, green: 16/256, blue: 40/256, alpha: 1)
        self.title = "Kill Application"
        self.action = #selector(Constants.appDelegate.killApplication)
    }
}
