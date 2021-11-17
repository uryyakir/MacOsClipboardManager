//
//  CellExtendedPopoverVC.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 06/11/2021.
//

import Foundation
import Cocoa

class CellExtendedPopoverVC: NSViewController {
    var scrollView = NSScrollView()
    var textField: NSTextField!

    func initView() {
        self.setupScrollableTextField()
        // add tracking inside the scrollView (to later support hover-detection)
        self.view.addTrackingArea(
            NSTrackingArea(
                rect: self.view.frame,
                options: [.activeInKeyWindow, .inVisibleRect, .mouseEnteredAndExited],
                owner: self
            )
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    static func newInstance() -> CellExtendedPopoverVC {
        guard let viewController = Storyboards.cellExtendedPopoverStoryboard.storyboard.instantiateController(
            withIdentifier: Storyboards.cellExtendedPopoverStoryboard.identifier
        ) as? CellExtendedPopoverVC else {
            fatalError("Unable to instantiate ViewController in CellPopover.storyboard")
        }
        viewController.view.setFrameSize(TableViewConstants.defaultCellExtendedPopoverFrameSize)
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
        // mark that user is examining the popover, thus preventing it from closing
        if let cellExtendedPopover = Constants.mainVC.clipboardTableVC.hoveredRow?.cellExtendedPopover {
            cellExtendedPopover.userExaminesExtendedPopover = true
        }
        // otherwise - it probably means user tried to enter popover via another row, thus overwriting the rows cellExtendedPopover attribute
    }

    override func mouseExited(with event: NSEvent) {
        // closing popover upon exit
        guard let extendedPopover = Constants.mainVC.clipboardTableVC.hoveredRow?.cellExtendedPopover else {
            return
        }
        extendedPopover.userExaminesExtendedPopover = false
        extendedPopover.close()
    }
}
