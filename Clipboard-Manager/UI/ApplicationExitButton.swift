//
//  ApplicationExitButton.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 18/11/2021.
//

import Foundation
import Cocoa

class ApplicationExitButton: NSButton {
    override init(frame: NSRect) {
        super.init(frame: frame)
        self.setupExitButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupExitButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .cyan
    }
}
