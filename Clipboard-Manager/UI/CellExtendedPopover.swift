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

class CellExtendedPopoverVC: NSViewController {
    var scrollView = NSScrollView()
    var textField: NSTextField!

    func initView() {
        self.setupScrollableTextField()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    static func newInstance() -> CellExtendedPopoverVC {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("CellPopover"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("CellExtendedPopoverVC")

        guard let viewController = storyboard.instantiateController(withIdentifier: identifier)
                as? CellExtendedPopoverVC else {
            fatalError("Unable to instantiate ViewController in CellPopover.storyboard")
        }
        return viewController
    }

    private func setupScrollableTextField() {
        AppDelegate.setupScrollView(
            parentView: view,
            scrollView: self.scrollView,
            leftConstant: 10,
            topConstant: 10,
            rightConstant: -10,
            bottomConstant: -10,
            hasScrollers: true
        )

        self.textField = self.setupTextField()
        self.constrainTextField()
        self.view.addTrackingArea(
            // add tracking inside the scrollView (to later support hover-detection)
            NSTrackingArea(
                rect: self.view.frame,
                options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited],
                owner: self
            )
        )
    }

    private func setupTextField() -> NSTextField {
        let textField = NSTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isEditable = false
        textField.drawsBackground = true
        return textField
    }

    private func constrainTextField() {
        self.scrollView.documentView = self.textField
        self.textField.heightAnchor.constraint(greaterThanOrEqualToConstant: self.view.bounds.height - 25).isActive = true
        self.textField.widthAnchor.constraint(greaterThanOrEqualToConstant: self.view.bounds.width - 25).isActive = true
    }

    override func mouseEntered(with event: NSEvent) {
        if let cellExtendedPopover = Constants.appDelegate.clipboardTableVC.hoveredRow?.cellExtendedPopover {
            cellExtendedPopover.userExaminesExtendedPopover = true
        }
        // otherwise - it probably means user tried to enter popover via another row, thus overwriting the rows cellExtendedPopover attribute
    }

    override func mouseExited(with event: NSEvent) {
        guard let extendedPopover = Constants.appDelegate.clipboardTableVC.hoveredRow?.cellExtendedPopover else {
            return
        }
        extendedPopover.userExaminesExtendedPopover = false
        extendedPopover.close()
    }
}
