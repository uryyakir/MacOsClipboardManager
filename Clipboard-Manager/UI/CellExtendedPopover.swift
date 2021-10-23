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
    var scrollView = NSScrollView()
    var textField: NSTextField!

    func initView() {
        self.setupScrollableTextField()
//        self.constrainScrollView()
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
        print("here")
        self.scrollView = NSScrollView()
        self.scrollView.backgroundColor = .clear
        self.view.addSubview(self.scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
        self.scrollView.backgroundColor = .clear
        self.scrollView.drawsBackground = false
        self.scrollView.hasVerticalScroller = true
        self.scrollView.hasHorizontalScroller = true

        self.textField = NSTextField(frame: NSRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        self.textField.textColor = .white
        self.textField.isEditable = false
        self.textField.drawsBackground = true
        self.constrainTextField()
    }

    private func constrainTextField() {
        self.textField.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.documentView = self.textField
        self.textField.leadingAnchor.constraint(lessThanOrEqualTo: self.scrollView.leadingAnchor, constant: 0).isActive = true
        self.textField.trailingAnchor.constraint(greaterThanOrEqualTo: self.scrollView.trailingAnchor, constant: 0).isActive = true
        self.textField.topAnchor.constraint(lessThanOrEqualTo: self.scrollView.topAnchor).isActive = true
        self.textField.bottomAnchor.constraint(greaterThanOrEqualTo: self.scrollView.bottomAnchor).isActive = true
    }
}
