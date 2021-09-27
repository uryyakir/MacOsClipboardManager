//
//  NSView.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 27/09/2021.
//

import Foundation
import Cocoa

extension NSView {
    var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }

        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}
