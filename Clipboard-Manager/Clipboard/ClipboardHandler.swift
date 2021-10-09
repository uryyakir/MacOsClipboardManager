//
//  ClipboardHandler.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 28/09/2021.
//

import Foundation
import AppKit

class ClipboardHandler {
    static func copyToClipboard(values: [String]) {
        Constants.pasteboard.declareTypes([.string], owner: nil)
        Constants.pasteboard.setString(values.joined(separator: "\n"), forType: .string)
    }
}
