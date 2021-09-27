//
//  ClipboardTableView.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 24/09/2021.
//

import Foundation
import AppKit

class ClipboardTableCell: NSTableCellView {

    init(frame: NSRect, stringValue: String) {
        super.init(frame: frame)

        let textField = generateCellTextField(stringValue: stringValue)
        self.textField = textField

        self.addSubview(self.textField!)
        constrainTextField()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func generateCellTextField(stringValue: String) -> NSTextField {
        let textField = NSTextField()
        textField.stringValue = stringValue
        textField.drawsBackground = false
        textField.isBordered = false
        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }

    private func constrainTextField() {
        self.addConstraints([
            NSLayoutConstraint(
                item: self.textField!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(
                item: self.textField!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 13
            ),
            NSLayoutConstraint(
                item: self.textField!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -13
            )
        ])
    }
}

class ClipboardTableVC: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    let scrollView = NSScrollView()
    let tableView = NSTableView()

    override func loadView() {
        self.view = NSView()
//        self.view.backgroundColor = .red
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayout() {
        constrainView()
        setupScrollView()
        setupTableView()
    }

    private func constrainView() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
//        self.view.topAnchor.constraint(equalTo: self.view.superview!.topAnchor, constant: 10).isActive = true
//        self.view.bottomAnchor.constraint(equalTo: self.view.superview!.bottomAnchor, constant: -10).isActive = true
//        self.view.leadingAnchor.constraint(equalTo: self.view.superview!.leadingAnchor, constant: 10).isActive = true
//        self.view.trailingAnchor.constraint(equalTo: self.view.superview!.trailingAnchor, constant: -10).isActive = true
    }

    private func setupScrollView() {
        self.view.addSubview(scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = NSColor.clear
        scrollView.drawsBackground = false
        self.view.addConstraints([
            NSLayoutConstraint(
                item: self.scrollView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0
            ),
            NSLayoutConstraint(
                item: self.scrollView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 23
            ),
            NSLayoutConstraint(
                item: self.scrollView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0
            ),
            NSLayoutConstraint(
                item: self.scrollView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0
            )
        ])
    }

    private func setupTableView() {
        tableView.frame = scrollView.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.backgroundColor = NSColor.clear
        tableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)

        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col"))
        col.minWidth = 200
        tableView.addTableColumn(col)

        scrollView.documentView = tableView
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = true
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 100
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let clipboardTableCell = ClipboardTableCell(frame: NSRect(), stringValue: "hello world")
        return clipboardTableCell
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView()
        return rowView
    }
}
