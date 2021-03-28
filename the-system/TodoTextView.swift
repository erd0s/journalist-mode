import Cocoa
import Carbon
import AppKit

class TodoTextView: TextView {
    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_Return && event.modifierFlags.contains(NSEvent.ModifierFlags.shift) {
            markDone(range: selectedRange())
        } else {
            super.keyDown(with: event)
        }
    }
    
    private func markDone(range: NSRange) {
        // Figure out where in the text we are
        textStorage?.addAttribute(.strikethroughStyle, value: 2, range: getLineRange(string: string as NSString, selectedRange: selectedRange()))
    }
}