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
    static let appDelegate = NSApplication.shared.delegate as! AppDelegate
    static let clipboardTestValues = ["hello", "my", "name", "is", "Uri", "Yakir", "help", "Hellman", "hell"]
    static let pasteboard = NSPasteboard.general
    static let dbHandler = DatabaseHandler()
    static let cwd = FileManager.default.currentDirectoryPath
    static let timeBeforeHoverPopover = 3.0  // 3 seconds hover required to open popover
    static var isInternalCopy: Bool = false  // tracking internal copy to clipboard, preventing from appending a new record to clipboard history
    static let textDefaultColor = NSColor(deviceRed: 8/255, green: 165/255, blue: 218/255, alpha: 1)
}
