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
        Constants.pasteboard.declareTypes([.html], owner: nil)
        Constants.pasteboard.setString(values.joined(separator: "<br>"), forType: .html)
        Constants.isInternalCopy = true

    }

    static func watchPasteboard() {
        // polling function to check for clipboard changes
        var changeCount = Constants.pasteboard.changeCount
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let copiedString = Constants.pasteboard.string(forType: .html) ?? Constants.pasteboard.string(forType: .string) {
                if Constants.pasteboard.changeCount != changeCount && !Constants.isInternalCopy {
                    Constants.dbHandler.insertCopiedValueToDB(copiedValue: copiedString, withCompletion: { response in
                        if response {
                            Constants.appDelegate.clipboardTableVC.arrayController.insert(
                                ClipboardObject(copiedString), atArrangedObjectIndex: 0
                            )  // updating tableView to include copied string
                        }
                    })
                    changeCount = Constants.pasteboard.changeCount
                } else if Constants.isInternalCopy {
                    // update changeCount and reset isInternalCopy
                    changeCount = Constants.pasteboard.changeCount
                    Constants.isInternalCopy = false
                }
            }
        }
    }
}
