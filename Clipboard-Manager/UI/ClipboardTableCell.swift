//
//  ClipboardTableCell.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 28/09/2021.
//

import Foundation
import Cocoa


class ClipboardTableCell: NSTableCellView {
    var stringValue: String?

    override init(frame: NSRect) {
        super.init(frame: frame)

        let textField = generateCellTextField()
        self.textField = textField

        self.addSubview(self.textField!)
        constrainTextField()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                item: self.textField!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(
                item: self.textField!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 13
            ),
            NSLayoutConstraint(
                item: self.textField!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -13
            )
        ])
    }
}


//class ClipboardTableCell: NSTableCellView {
//    var stringValue: String?
//
//    init(frame: NSRect, stringValue: String) {
//        super.init(frame: frame)
//
//        let textField = generateCellTextField(stringValue: stringValue)
//        self.textField = textField
//        self.stringValue = stringValue
//
//        self.addSubview(self.textField!)
//        constrainTextField()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func generateCellTextField(stringValue: String) -> NSTextField {
//        let textField = NSTextField()
//        textField.stringValue = stringValue
//        textField.drawsBackground = false
//        textField.isBordered = false
//        textField.isEditable = false
//        textField.translatesAutoresizingMaskIntoConstraints = false
//
//        return textField
//    }
//
//    private func constrainTextField() {
//        self.addConstraints([
//            NSLayoutConstraint(
//                item: self.textField!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0
//            ),
//            NSLayoutConstraint(
//                item: self.textField!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 13
//            ),
//            NSLayoutConstraint(
//                item: self.textField!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -13
//            )
//        ])
//    }
//}
