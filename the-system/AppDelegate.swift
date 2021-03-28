//
//  AppDelegate.swift
//  the-system
//
//  Created by Dirk on 28/02/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var documentController: DocumentController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        documentController!.setupHotkeys()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        documentController = DocumentController()
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        return false
    }
    
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
}

