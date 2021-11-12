//
//  Constants.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 28/09/2021.
//

import Cocoa
import Foundation

enum KeyCodes: Int {
    case ESC = 53
    case ENTER = 36
    case KEYUP = 126
    case KEYDOWN = 125
}

enum TextNewLine: String {
    case RAW = "\n"
    case HTML = "<br>"
}

enum RegexPatterns: String {
    case HTMLImageSrcRE = "src=\"(.*?)\""
    case b64ImageSignature = "base64"
    case b64ImageRE = "base64(.*)"
}

enum DBConstants: String {
    case DBFilename = "db.sqlite3"
    case tableName = "clipboard"
    case clipboardContentRawCol = "CLIPBOARD_CONTENT_RAW"
    case clipboardContentHTMLCol = "CLIPBOARD_CONTENT_HTML"
    case insertionTimeCol = "INSERTION_TIME"
    case selectAllHistoryQuery = "SELECT * FROM clipboard ORDER BY INSERTION_TIME desc"
}

struct Storyboard {
    let storyboard: NSStoryboard
    let identifier: NSStoryboard.SceneIdentifier

    init(storyboardName: String, storyboardScene: String) {
        self.storyboard = NSStoryboard(name: NSStoryboard.Name(storyboardName), bundle: nil)
        self.identifier = NSStoryboard.SceneIdentifier(storyboardScene)
    }
}

class Storyboards {
    static let mainStoryboard = Storyboard(storyboardName: "Main", storyboardScene: "ViewController")
    static let cellExtendedPopoverStoryboard = Storyboard(storyboardName: "CellPopover", storyboardScene: "CellExtendedPopoverVC")
}

struct Constants {
    // swiftlint:disable force_cast
    // setup process
    static let applicationIcon = NSImage(named: NSImage.Name("clipboard-icon"))
    static let NSViewsBackgroundColor = NSColor.clear
    static let appDelegate = NSApplication.shared.delegate as! AppDelegate
    static let mainVC = MainViewController.newInstance()
    static let pasteboard = NSPasteboard.general
    static let dbHandler = DatabaseHandler()
    static let cwd = FileManager.default.currentDirectoryPath
    // table VC constants
    static let caseInsensitive: Bool = true
    static let diacriticInsensitive: Bool = true
    static let predicateOptions = (Constants.caseInsensitive ? "c" : "") + (Constants.diacriticInsensitive ? "d" : "")
    static let predicateMatchClipboardObjectAttribute: String = "rawClipboardString"
    static let cellTextFieldClipboardObjectAttribute: String = "clipboardAttributedString"
    static let tableViewColumnName = "col"
    static let cellTrackingDataKey = "row"
    static let cellExtendedPopoverWidth = CellExtendedPopoverVC.newInstance().view.bounds.width
    static let timeBeforeHoverPopover = 3.0  // 3 seconds hover required to open popover
    static let textDefaultColor = NSColor(deviceRed: 8/255, green: 165/255, blue: 218/255, alpha: 1)
    static let cellHoverBackgroundColor = NSColor(deviceRed: 135/255, green: 206/255, blue: 250/255, alpha: 0.3)
    static let cellBorderColor = NSColor(deviceRed: 30/255, green: 144/255, blue: 255/255, alpha: 0.2).cgColor
    static let cellSelectionBorderAlternationInterval = 0.3
    static let cellSelectionBorderColorIterations = 3
    static let cellSelectionBorderColor = NSColor(deviceRed: 249/255, green: 240/255, blue: 24/255, alpha: 0.4).cgColor
    static let timeBeforeExtendedPopoverClose = 1.0
    // other constants
    static var isInternalCopy: Bool = false  // tracking internal copy to clipboard, preventing from appending a new record to clipboard history
    static let failedImageLoadPlaceholder = "<image couldn't be extracted>"

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
