//
//  ViewController.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 23/09/2021.
//

import Cocoa
import AVFoundation

class MainViewController: NSViewController {
    var clipboardTableVC = ClipboardTableVC()
    let clipboardSearchFieldVC = ClipboardSearchFieldVC()
    let applicationExitButton = ApplicationExitButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        // register for clicks outside the NSWindow, that are set to close the application popover
        NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: OperationQueue.main) { _ in
            Constants.appDelegate.closePopover(sender: self)
        }
        ClipboardHandler.watchPasteboard()
    }

    static func newInstance() -> MainViewController {
        guard let viewController = Storyboards.mainStoryboard.storyboard.instantiateController(
            withIdentifier: Storyboards.mainStoryboard.identifier
        ) as? MainViewController else {
            fatalError("Unable to instantiate ViewController in Main.storyboard")
        }
        viewController.view.setFrameSize(TableViewConstants.defaultMainFrameSize)
        return viewController
    }

    func closeCellExtendedPopoverIfOpen() -> Bool {
        if let hoveredRow = self.clipboardTableVC.hoveredRow {
            if let cellExtendedPopover = hoveredRow.cellExtendedPopover {
                cellExtendedPopover.close()
                self.clipboardTableVC.hoveredRow!.cellExtendedPopover = nil
                return true
            }
        }
        return false
    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        switch Int(event.keyCode) {
        case (KeyCodes.ESC.rawValue):  // ESC key
            // if an extended cell popover is open - close it
            // otherwise - close application main popover
            if !self.closeCellExtendedPopoverIfOpen() {
                Constants.appDelegate.closePopover(sender: self)
            }
        case KeyCodes.ENTER.rawValue:  // Enter key
            let selectedValues = (self.clipboardTableVC.getSelectedValues())!
            ClipboardHandler.copyToClipboard(values: selectedValues)
            TableViewConstants.cellSelectionSound?.play()

        default:
            break
        }
    }

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
        self.clipboardSearchFieldVC.view.topAnchor.constraint(equalTo: self.applicationExitButton.bottomAnchor, constant: 10).isActive = true
        self.clipboardSearchFieldVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.clipboardSearchFieldVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
    }

    func setupExitButton() {
        self.view.addSubview(self.applicationExitButton)
        self.constrainExitButton()
    }

    private func constrainExitButton() {
        self.applicationExitButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        self.applicationExitButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.applicationExitButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
}
