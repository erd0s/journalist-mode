//
//  DocumentController.swift
//  the-system
//
//  Created by Dirk on 28/02/2021.
//

import Cocoa
import HotKey

enum SystemPart {
    case Doing
    case Todo
    case Distractions
}

class DocumentController: NSDocumentController {
    // MARK: - Hotkeys

    var activateTodo, activateDoing, activateDistractions: HotKey?

    func setupHotkeys() {
        activateDoing = HotKey(key: .j, modifiers: [.command, .shift])
        activateDoing?.keyDownHandler = { self.showAll(andActivate: .Doing) }

        activateTodo = HotKey(key: .k, modifiers: [.command, .shift])
        activateTodo!.keyDownHandler = { self.showAll(andActivate: .Todo) }

        activateDistractions = HotKey(key: .l, modifiers: [.command, .shift])
        activateDistractions?.keyDownHandler = { self.showAll(andActivate: .Distractions) }
    }

    func showAll(andActivate: SystemPart) {
        NSRunningApplication.current.activate(options: [NSApplication.ActivationOptions.activateAllWindows, NSApplication.ActivationOptions.activateIgnoringOtherApps])

        // TODO: We're expecting there to always be a single opened document at any one time, check for that here, maybe
        //       create a new one if we need to

        if (documents.count == 0) {
            // TODO: Create?
            print("hmmm")
        } else if (documents.count == 1) {
            (documents[0] as! Document).enableWindow(type: andActivate)
        } else {
            // TODO: More unexpected behaviour
            print("hmmm")
        }
    }
    
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        documents.forEach { (document) in
            document.close()
        }
        return try super.openUntitledDocumentAndDisplay(true)
    }
}
