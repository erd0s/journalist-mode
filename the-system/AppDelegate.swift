import Cocoa

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
    
    @IBAction func debugDoingText(_ sender: Any) {
        if let doc = documentController?.documents.first {
            if let swc = doc.windowControllers.first {
                if let svc = swc.contentViewController as? SingleViewController {
                    svc.doingTextView.debugIndent()
                    svc.doingTextView.debug()
                }
            }
        }
    }
}

