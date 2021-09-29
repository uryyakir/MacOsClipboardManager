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
}

struct Constants {
    // swiftlint:disable force_cast
    static let appDelegate = NSApplication.shared.delegate as! AppDelegate
    static let clipboardTestValues = ["hello", "my", "name", "is", "Uri", "Yakir", "help", "Hellman", "hell"]
}
