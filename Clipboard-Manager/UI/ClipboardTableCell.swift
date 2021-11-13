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
        self.layer?.borderColor = Constants.cellBorderColor
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

    func flashSelection() {
        // let the user know he has selected some cell/s
        let originalBorderWidth = self.layer!.borderWidth
        var iteration = 0
        Timer.scheduledTimer(withTimeInterval: Constants.cellSelectionBorderAlternationInterval, repeats: true, block: { timer in
            self.layer?.borderWidth = originalBorderWidth + 1.5
            self.layer!.borderColor = Constants.cellSelectionBorderColor
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.cellSelectionBorderAlternationInterval / 2, execute: {
                self.layer?.borderWidth = originalBorderWidth
                self.layer?.borderColor = Constants.cellBorderColor
            })
            iteration += 1
            if iteration >= Constants.cellSelectionBorderColorIterations { timer.invalidate() }
        })
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        switch Int(event.keyCode) {
        case KeyCodes.ENTER.rawValue, KeyCodes.ESC.rawValue:
            // prevent the default `dooonk` sound for those
            return true
        default:
            return false
        }
    }
}
