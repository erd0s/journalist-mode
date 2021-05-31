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
        if let firstDoc = documents.first as? Document {
            firstDoc.enableWindow(type: andActivate)
        }
        else {
            print("Didn't find any windows to activate")
        }
    }
    
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        documents.forEach { (document) in
            document.close()
        }
        return try super.openUntitledDocumentAndDisplay(true)
    }
}
