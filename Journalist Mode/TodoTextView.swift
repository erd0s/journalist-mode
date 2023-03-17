import Cocoa
import Carbon
import AppKit

class TodoTextView: TextView {
    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_Return && event.modifierFlags.contains(NSEvent.ModifierFlags.shift) {
            markDone()
        }
        // Unmark done - CMD+Shift+X
        else if event.keyCode == kVK_ANSI_X && event.modifierFlags.contains(NSEvent.ModifierFlags.command) && event.modifierFlags.contains(NSEvent.ModifierFlags.shift) {
            unmarkDone()
        }
        else {
            super.keyDown(with: event)
        }
    }
    
    func markDone() {
        // Figure out where in the text we are
        let lineNumber = getLineNumber()
        let lineRange = getLineRange(forLineNumber: lineNumber)
        
        let lineToReplace = NSMutableAttributedString(attributedString: textStorage!.attributedSubstring(from: lineRange))
        lineToReplace.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: lineToReplace.length))
        
        if shouldChangeText(in: lineRange, replacementString: lineToReplace.string) {
            textStorage?.replaceCharacters(in: lineRange, with: lineToReplace)
            didChangeText()
        }
    }
    
    func unmarkDone() {
        // Figure out where in the text we are
        let lineNumber = getLineNumber()
        let lineRange = getLineRange(forLineNumber: lineNumber)
        
        let lineToReplace = NSMutableAttributedString(attributedString: textStorage!.attributedSubstring(from: lineRange))
        lineToReplace.removeAttribute(.strikethroughStyle, range: NSRange(location: 0, length: lineToReplace.length))
        
        if shouldChangeText(in: lineRange, replacementString: lineToReplace.string) {
            textStorage?.replaceCharacters(in: lineRange, with: lineToReplace)
            didChangeText()
        }
    }
}
