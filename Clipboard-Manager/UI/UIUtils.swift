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
        setupClipboardTableVC()
    }

    private func setupStatusBarItem() {
        // This function setups the application icon on the client's taskbar
        // & defines popover functionality
        if let button = self.statusItem.button {
            button.image = NSImage(named: NSImage.Name("clipboard-icon"))
            button.action = #selector(AppDelegate.togglePopover(_:))

            self.popover.setValue(true, forKey: "shouldHideAnchor")
            self.popover.contentViewController = self.viewController
            self.popover.animates = false
        }
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

    private func setupClipboardTableVC() {
        self.clipboardTableVC.view.frame = self.viewController.view.frame
        self.viewController.view.addSubview(self.clipboardTableVC.view)
        constrainClipboardTableVC()
    }

    private func constrainClipboardTableVC() {
        self.clipboardTableVC.view.topAnchor.constraint(equalTo: self.viewController.view.topAnchor, constant: 0).isActive = true
        self.clipboardTableVC.view.bottomAnchor.constraint(equalTo: self.viewController.view.bottomAnchor, constant: 0).isActive = true
        self.clipboardTableVC.view.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor, constant: 0).isActive = true
        self.clipboardTableVC.view.trailingAnchor.constraint(equalTo: self.viewController.view.trailingAnchor, constant: 0).isActive = true
    }
}
