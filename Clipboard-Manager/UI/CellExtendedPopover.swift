//
//  CellExtendedPopover.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 16/10/2021.
//

import Foundation
import Cocoa

class CellExtendedPopover: NSPopover {
    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CellExtendedPopoverVC: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .green
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
}
