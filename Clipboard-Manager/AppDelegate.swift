//
//  AppDelegate.swift
//  Clipboard Manager
//
//  Created by Uri Yakir on 23/09/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()

    func applicationWillFinishLaunching(_ notification: Notification) {
        self.setupApplicationUI()
        Constants.makeConstantsAssertions()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
