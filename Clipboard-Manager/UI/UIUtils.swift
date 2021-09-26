//
//  UIUtils.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 27/09/2021.
//

import Foundation
import Cocoa

extension AppDelegate {
    func setupApplicationUI() {
        setupStatusBarItem()
        setupApplicationClipboardMenu()
    }

    private func setupStatusBarItem() {
        // This function setups the application icon on the client's taskbar
        // & defines popover functionality
        if let button = self.statusItem.button {
            button.image = NSImage(named: NSImage.Name("clipboard-icon"))
            button.action = #selector(AppDelegate.togglePopover(_:))

            self.popover.setValue(true, forKey: "shouldHideAnchor")
            self.popover.contentViewController = ViewController.newInstance()
            self.popover.animates = false
        }
    }

    private func setupApplicationClipboardMenu() {
        // This function setups the NSMenu that will hold the client's clipboard history
        let clipboardMenu = ClipboardMenu(title: "test title")
        statusItem.menu = clipboardMenu
    }

    @objc private func togglePopover(_ sender: NSStatusItem) {
        if self.popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    private func showPopover(sender: Any?) {
        if let button = self.statusItem.button {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }

    private func closePopover(sender: Any?) {
        self.popover.performClose(sender)
    }
}
