//
//  ViewController.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 23/09/2021.
//

import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // register for clicks outside the NSWindow, that are set to close the application popover
        NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: OperationQueue.main) { _ in
            Constants.appDelegate.closePopover(sender: self)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    static func newInstance() -> ViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("ViewController")

        guard let viewController = storyboard.instantiateController(withIdentifier: identifier)
                as? ViewController else {
            fatalError("Unable to instantiate ViewController in Main.storyboard")
        }
        return viewController
    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        switch Int(event.keyCode) {
        case (KeyCodes.ESC):  // ESC key
            Constants.appDelegate.closePopover(sender: self)

        case KeyCodes.ENTER:  // Enter key
            let selectedValues = (Constants.appDelegate.clipboardTableVC.getSelectedValues())!
            ClipboardHandler.copyToClipboard(values: selectedValues)

        default:
            break
        }
    }
}
