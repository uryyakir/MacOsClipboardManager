//
//  ClipboardHandler.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 28/09/2021.
//

import Foundation
import AppKit

struct ClipboardCopiedObject {
    let copiedValueRaw: String?
    let copiedValueHTML: String?
}

class ClipboardHandler {
    static func copyToClipboard(values: [ClipboardObject]) {
        Constants.pasteboard.declareTypes([.html, .string], owner: nil)
        // set clipboard contents for applications supporting HTML (e.g Chrome, Microsoft Word etc.)
        Constants.pasteboard.setString(
            values.map({
                ($0.HTMLClipboardString ?? $0.rawClipboardString)!.prepareForAttributedString
            }).joined(separator: "<br>"),
            forType: .html
        )
        // set clipboard contents for applications not supporting HTML (e.g. notes, XCode etc.)
        Constants.pasteboard.setString(
            values.map({
                ($0.rawClipboardString ?? $0.HTMLClipboardString )!
            }).joined(separator: "\n"),
            forType: .string
        )
        Constants.isInternalCopy = true
    }

    static func watchPasteboard() {
        // polling function to check for clipboard changes
        var changeCount = Constants.pasteboard.changeCount
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let copiedStringRaw = Constants.pasteboard.string(forType: .string), copiedStringHTML = Constants.pasteboard.string(forType: .html)
            if copiedStringRaw != nil || copiedStringHTML != nil {
                let clipboardCopiedObj = ClipboardCopiedObject(copiedValueRaw: copiedStringRaw, copiedValueHTML: copiedStringHTML)
                if Constants.pasteboard.changeCount != changeCount && !Constants.isInternalCopy {
                    Constants.dbHandler.insertCopiedValueToDB(copiedObject: clipboardCopiedObj, withCompletion: { response in
                        if response {
                            Constants.appDelegate.clipboardTableVC.arrayController.insert(
                                ClipboardObject(clipboardCopiedObj), atArrangedObjectIndex: 0
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
