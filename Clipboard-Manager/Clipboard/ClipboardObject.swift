//
//  ClipboardObject.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 31/10/2021.
//

import Foundation
import Cocoa

class ClipboardObject: NSObject {
    @objc dynamic var rawClipboardString: String?
    @objc dynamic var HTMLClipboardString: String?
    @objc dynamic var clipboardString: String
    @objc dynamic var clipboardAttributedString: NSMutableAttributedString

    static func colorAttributedString(string: NSMutableAttributedString, color: NSColor) {
        string.addAttribute(
            .foregroundColor,
            value: color,
            range: NSRange(location: 0, length: string.length)
        )
    }

    init(_ clipboardObject: ClipboardCopiedObject) {
        self.rawClipboardString = clipboardObject.copiedValueRaw
        self.HTMLClipboardString = clipboardObject.copiedValueHTML
        self.clipboardString = (clipboardObject.copiedValueHTML ?? clipboardObject.copiedValueRaw)!.prepareForAttributedString
        self.clipboardAttributedString = self.clipboardString.htmlToAttributedString(
            resizeToWidth: nil, resizeToHeight: Constants.appDelegate.clipboardTableVC.tableView.rowHeight + 20.0
        )!
        ClipboardObject.colorAttributedString(string: self.clipboardAttributedString, color: Constants.textDefaultColor)
    }
}
