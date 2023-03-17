import Cocoa

class SingleWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        NSWindow.allowsAutomaticWindowTabbing = false
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        if let screen = window?.screen ?? NSScreen.main {
            window!.setFrame(screen.visibleFrame, display: true)
        }
    }
    
    func selectPart(type: SystemPart) {
        (contentViewController as! SingleViewController).selectPart(type: type)
    }
}
