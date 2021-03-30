import Cocoa

class Window: NSWindow {
    override var canBecomeKey: Bool{ return true }
    override var canBecomeMain: Bool{ return true }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        isOpaque = false
        backgroundColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
        
    func selected() {
        backgroundColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func deselected() {
        backgroundColor = NSColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
}
