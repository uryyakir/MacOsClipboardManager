//
//  CellExtendedPopover.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 16/10/2021.
//

import Foundation
import Cocoa

class CellExtendedPopover: NSPopover {
    var userExaminesExtendedPopover: Bool = false

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
