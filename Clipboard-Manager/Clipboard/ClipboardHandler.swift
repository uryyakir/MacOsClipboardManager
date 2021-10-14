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

    static func watchPasteboard() {
        // polling function to check for clipboard changes
        var changeCount = Constants.pasteboard.changeCount
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let copiedString = Constants.pasteboard.string(forType: .string) {
                if Constants.pasteboard.changeCount != changeCount {
                    Constants.dbHandler.insertCopiedValueToDB(copiedValue: copiedString)
                    changeCount = Constants.pasteboard.changeCount
                }
            }
        }
    }
}
