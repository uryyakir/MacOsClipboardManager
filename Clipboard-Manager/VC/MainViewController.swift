//
//  ViewController.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 23/09/2021.
//

import Cocoa

class MainViewController: NSViewController {
    var clipboardTableVC = ClipboardTableVC()
    let clipboardSearchFieldVC = ClipboardSearchFieldVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        // register for clicks outside the NSWindow, that are set to close the application popover
        NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: OperationQueue.main) { _ in
            Constants.appDelegate.closePopover(sender: self)
        }
        ClipboardHandler.watchPasteboard()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    static func newInstance() -> MainViewController {
        guard let viewController = Storyboards.mainStoryboard.storyboard.instantiateController(
            withIdentifier: Storyboards.mainStoryboard.identifier
        ) as? MainViewController else {
            fatalError("Unable to instantiate ViewController in Main.storyboard")
        }
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

        default:
            break
        }
    }
}
