import Cocoa
import Carbon

class TextView: NSTextView {
    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_Escape {
            NSRunningApplication.current.hide()
        } else {
            super.keyDown(with: event)
        }
    }
}
