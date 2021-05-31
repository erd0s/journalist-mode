import Cocoa

enum DisplayType {
    case Single
    case Multi
}

var displayType: DisplayType = .Single

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var documentController: DocumentController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        documentController!.setupHotkeys()
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

