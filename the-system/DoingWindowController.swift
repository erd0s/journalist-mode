import Cocoa

class DoingWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        let screenWidth = NSScreen.main!.visibleFrame.width
        let screenHeight = NSScreen.main!.visibleFrame.height
        let buffer = CGFloat(10.0)
        let doingRect = NSRect(x: buffer, y: buffer, width: screenWidth/2 - buffer*1.5, height: screenHeight - buffer * 2)
        window?.setFrame(doingRect, display: true)
    }

}
