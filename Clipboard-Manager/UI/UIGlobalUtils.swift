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
        self.setupStatusBarItem()
        Constants.mainVC.setupClipboardSearchField()
        Constants.mainVC.setupClipboardTableVC()
    }

    private func setupStatusBarItem() {
        // This function setups the application icon on the client's taskbar
        // & defines popover functionality
        if let button = self.statusItem.button {
            button.image = Constants.applicationIcon
            button.action = #selector(AppDelegate.togglePopover(_:))

            self.popover.setValue(true, forKey: "shouldHideAnchor")
            self.popover.contentViewController = Constants.mainVC
            self.popover.animates = false
        }
    }

    @objc private func togglePopover(_ sender: NSStatusItem) {
        if self.popover.isShown {
            self.closePopover(sender: sender)
        } else {
            self.showPopover(sender: sender)
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

    static func setupScrollView(
        parentView: NSView,
        scrollView: NSScrollView,
        leftConstant: CGFloat = 0,
        topConstant: CGFloat = 0,
        rightConstant: CGFloat = 0,
        bottomConstant: CGFloat = 0,
        hasScrollers: Bool = false
    ) {
        // shortcut function for setting-up and constraining a scroll-view to its parent
        parentView.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = Constants.NSViewsBackgroundColor
        scrollView.drawsBackground = false
        if hasScrollers {
            scrollView.hasHorizontalScroller = true
            scrollView.hasVerticalScroller = true
        }
        parentView.addConstraints([
            NSLayoutConstraint(
                item: scrollView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .leading,
                multiplier: 1.0,
                constant: leftConstant
            ),
            NSLayoutConstraint(
                item: scrollView,
                attribute: .top,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .top,
                multiplier: 1.0,
                constant: topConstant
            ),
            NSLayoutConstraint(
                item: scrollView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .trailing,
                multiplier: 1.0,
                constant: rightConstant
            ),
            NSLayoutConstraint(
                item: scrollView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: bottomConstant
            )
        ])
    }

    func resizeImageWithRatio(image: NSImage?, resizeToWidth: Double? = nil, resizeToHeight: Double? = nil) -> NSImage? {
        if image == nil { return nil }
        let imageWidth = image!.size.width
        let imageHeight = image!.size.height
        let resizeRatio = (resizeToWidth ?? resizeToHeight!) / imageWidth
        return image!.resized(to: NSSize(width: resizeRatio * imageWidth, height: resizeRatio * imageHeight))
    }
}

extension MainViewController {
    func setupClipboardTableVC() {
        Constants.mainVC.clipboardTableVC.view.frame = self.view.frame
        self.view.addSubview(self.clipboardTableVC.view)
        self.constrainClipboardTableVC()
    }

    private func constrainClipboardTableVC() {
        Constants.mainVC.clipboardTableVC.view.topAnchor.constraint(
            equalTo: Constants.mainVC.clipboardSearchFieldVC.view.topAnchor, constant: 10).isActive = true
        self.clipboardTableVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        self.clipboardTableVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        self.clipboardTableVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
    }

    func setupClipboardSearchField() {
        self.view.addSubview(self.clipboardSearchFieldVC.view)
        self.constrainClipboardSearchField()
    }

    private func constrainClipboardSearchField() {
        self.clipboardSearchFieldVC.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        self.clipboardSearchFieldVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.clipboardSearchFieldVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
    }
}
