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
        setupClipboardSearchField()
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

    func closePopover(sender: Any?) {
        self.popover.performClose(sender)
    }

    private func setupClipboardTableVC() {
        self.clipboardTableVC.view.frame = self.viewController.view.frame
        self.viewController.view.addSubview(self.clipboardTableVC.view)
        constrainClipboardTableVC()
    }

    private func constrainClipboardTableVC() {
        self.clipboardTableVC.view.topAnchor.constraint(equalTo: self.clipboardSearchFieldVC.view.topAnchor, constant: 10).isActive = true
        self.clipboardTableVC.view.bottomAnchor.constraint(equalTo: self.viewController.view.bottomAnchor, constant: 0).isActive = true
        self.clipboardTableVC.view.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor, constant: 0).isActive = true
        self.clipboardTableVC.view.trailingAnchor.constraint(equalTo: self.viewController.view.trailingAnchor, constant: 0).isActive = true
    }

    private func setupClipboardSearchField() {
        self.viewController.view.addSubview(self.clipboardSearchFieldVC.view)
        constrainClipboardSearchField()
    }

    private func constrainClipboardSearchField() {
        self.clipboardSearchFieldVC.view.topAnchor.constraint(equalTo: self.viewController.view.topAnchor, constant: 10).isActive = true
        self.clipboardSearchFieldVC.view.leadingAnchor.constraint(equalTo: self.viewController.view.leadingAnchor, constant: 10).isActive = true
        self.clipboardSearchFieldVC.view.trailingAnchor.constraint(equalTo: self.viewController.view.trailingAnchor, constant: -10).isActive = true
    }

    static func setupScrollView(parentView: NSView, scrollView: NSScrollView) {
        parentView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = NSColor.clear
        scrollView.drawsBackground = false
        parentView.addConstraints([
            NSLayoutConstraint(
                item: scrollView, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1.0, constant: 0
            ),
            NSLayoutConstraint(
                item: scrollView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1.0, constant: 23
            ),
            NSLayoutConstraint(
                item: scrollView, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1.0, constant: 0
            ),
            NSLayoutConstraint(
                item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1.0, constant: 0
            )
        ])
    }
}
