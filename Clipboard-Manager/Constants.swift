//
//  Constants.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 28/09/2021.
//

import Cocoa
import Foundation

enum KeyCodes {
    static let ESC = 53
    static let ENTER = 36
    static let KEYUP = 126
    static let KEYDOWN = 125
}

struct Constants {
    // swiftlint:disable force_cast
    // setup process
    static let applicationIcon = NSImage(named: NSImage.Name("clipboard-icon"))
    // table VC constants
    static let caseInsensitive: Bool = true
    static let diacriticInsensitive: Bool = true
    static let predicateOptions = (Constants.caseInsensitive ? "c" : "") + (Constants.diacriticInsensitive ? "d" : "")
    static let predicateMatchClipboardObjectAttribute: String = "rawClipboardString"
    static let cellTextFieldClipboardObjectAttribute: String = "clipboardAttributedString"
    static let tableViewColumnName = "col"
    static let cellExtendedPopoverWidth = CellExtendedPopoverVC.newInstance().view.bounds.width
    // other constants
    static let appDelegate = NSApplication.shared.delegate as! AppDelegate
    static let pasteboard = NSPasteboard.general
    static let dbHandler = DatabaseHandler()
    static let cwd = FileManager.default.currentDirectoryPath
    static let timeBeforeHoverPopover = 3.0  // 3 seconds hover required to open popover
    static var isInternalCopy: Bool = false  // tracking internal copy to clipboard, preventing from appending a new record to clipboard history
    static let textDefaultColor = NSColor(deviceRed: 8/255, green: 165/255, blue: 218/255, alpha: 1)
    static let cellHoverBackgroundColor = NSColor(deviceRed: 135/255, green: 206/255, blue: 250/255, alpha: 0.3)
    static let timeBeforeExtendedPopoverClose = 1.0

    static func makeConstantsAssertions() {
        Constants.validateClipboardObjectAttributes()
    }

    private static func validateClipboardObjectAttributes() {
        let attributesMirror = Mirror(
            reflecting: ClipboardObject(
                ClipboardCopiedObject(
                    copiedValueRaw: "dummy",
                    copiedValueHTML: "dummy"
                )
            )
        ).children.compactMap { $0.label }
        assert(
            attributesMirror.contains(Constants.predicateMatchClipboardObjectAttribute) &&
            attributesMirror.contains(Constants.cellTextFieldClipboardObjectAttribute)
        )
    }
}
