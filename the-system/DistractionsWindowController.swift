import Cocoa

class DistractionsWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        let screenWidth = NSScreen.main!.visibleFrame.width
        let screenHeight = NSScreen.main!.visibleFrame.height
        let buffer = CGFloat(10.0)
        
        let distractionsRect = NSRect(x: screenWidth/2 + buffer/2, y: buffer, width: screenWidth/2 - buffer * 1.5, height: screenHeight/2 - buffer * 1.5)

        window?.setFrame(distractionsRect, display: true)
    }
}
