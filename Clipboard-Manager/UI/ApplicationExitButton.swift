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
        let title = NSMutableAttributedString(string: "X ")
        title.setFont(size: (TableViewConstants.defaultAttributedStringFontSize))
        self.attributedTitle = title
        self.action = #selector(Constants.appDelegate.closePopover)
    }

    func setupExitButton() {
        self.backgroundColor = NSColor(deviceRed: 16/256, green: 16/256, blue: 40/256, alpha: 1)
        // setup title
        let title = NSMutableAttributedString(string: "Quit  ⌘Q")
        title.setFont(size: (TableViewConstants.defaultAttributedStringFontSize))
        title.addAttribute(.foregroundColor, value: NSColor.white, range: NSRange(location: 0, length: 4))
        title.addAttribute(.foregroundColor, value: NSColor.systemGray, range: NSRange(location: 5, length: title.length - 5))
        self.attributedTitle = title
        // setup click action
        self.action = #selector(Constants.appDelegate.killApplication)
    }
}
