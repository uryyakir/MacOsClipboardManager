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
        Constants.mainVC.setupMinimizeButton()
        Constants.mainVC.setupQuitButton()
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

    @objc func killApplication() {
        NSApplication.shared.terminate(self)
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

    @objc func closePopover(sender: Any?) {
        self.popover.close()
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

    func scaleApplicationWindowsToMonitorSize() {
        /*
         Make all necessary adjustments to the different attributes constructing the application's UI.
         Make sure to scale everything according to current client's screen resolution, scaled in comparison to my home-monitor
         */
        if let currentScreenSize = Constants.currentScreenSize {
            let widthRatio = (currentScreenSize.width / TableViewConstants.relativeToScreenSize.width)
            let heightRatio = (currentScreenSize.height / TableViewConstants.relativeToScreenSize.height)
            let ratiosAverage = (widthRatio + heightRatio) / 2
            TableViewConstants.defaultMainFrameSize.width *= widthRatio
            TableViewConstants.defaultMainFrameSize.height *= heightRatio
            TableViewConstants.defaultCellExtendedPopoverFrameSize.width *= widthRatio
            TableViewConstants.defaultCellExtendedPopoverFrameSize.height *= heightRatio

            TableViewConstants.defaultAttributedStringFontSize *= ratiosAverage
            TableViewConstants.defaultCellHeight *= ratiosAverage
        }
    }
}
