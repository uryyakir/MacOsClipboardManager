//
//  ClipboardTableCell.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 28/09/2021.
//

import Foundation
import Cocoa

class ClipboardTableCell: NSTableCellView {

    override init(frame: NSRect) {
        super.init(frame: frame)
        self.drawBorder()

        let textField = self.generateCellTextField()
        self.textField = textField

        self.addSubview(self.textField!)
        self.constrainTextField()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func drawBorder() {
        self.wantsLayer = true
        self.layer?.borderWidth = 2
        self.layer?.cornerRadius = 5
        self.layer?.borderColor = NSColor(deviceRed: 30/255, green: 144/255, blue: 255/255, alpha: 0.2).cgColor
    }

    private func generateCellTextField() -> NSTextField {
        let textField = NSTextField()
        textField.drawsBackground = false
        textField.isBordered = false
        textField.isEditable = false
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }

    private func constrainTextField() {
        self.addConstraints([
            NSLayoutConstraint(
                item: self.textField!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 5
            ),
            NSLayoutConstraint(
                item: self.textField!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 10
            ),
            NSLayoutConstraint(
                item: self.textField!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0
            )
        ])
    }
}
