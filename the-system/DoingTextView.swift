import Cocoa
import Carbon
import AppKit

class DoingTextView: TextView {
    let indentWidth = 15
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_Return && event.modifierFlags.contains(NSEvent.ModifierFlags.shift) {
            completeTask()
        } else if event.keyCode == kVK_Return {
            newTask()
            super.keyDown(with: event)
        } else {
            super.keyDown(with: event)
        }
    }
    
    func newTask() {
        // Check if the line they've got selected already has a strikethrough on it
        var lineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
        while isLineCompleted(range: lineRange) {
            lineRange = previousLineRangeOrNil(selection: lineRange)!
        }
        
        var indent: CGFloat = 0.0
        textStorage?.enumerateAttribute(.paragraphStyle, in: lineRange, options: [], using: { (something, someRange, somethingElse) in
            if something != nil {
                indent = (something as! NSParagraphStyle).headIndent
            }
        })
        indent = indent + 15.0
        
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = indent
        style.headIndent = indent
        
        typingAttributes = [NSAttributedString.Key.paragraphStyle: style]
    }
    
    func completeTask() {
        // TODO - If
        
        
        // Mark this line done
        let lineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
        textStorage?.addAttribute(.strikethroughStyle, value: 2, range: lineRange)
        
        // Change the colour
        textStorage?.addAttribute(.foregroundColor, value: NSColor.gray, range: lineRange)
        
        // Put the cursor at the end of the previous line
        let previousLineRange = NSRange(location: lineRange.location, length: 0)
        setSelectedRange(previousLineRange)
    }
    
    // MARK: - Helper functions
    
    private func isLineCompleted(range: NSRange) -> Bool {
        var isCompleted = false
        textStorage?.enumerateAttribute(.strikethroughStyle, in: range, options: [], using: { (value, range, whatever) in
            if value != nil {
                if let x = value as? Int {
                    if x != 0 {
                        isCompleted = true
                    }
                }
            }
        })
        
        return isCompleted
    }
    
    private func previousLineRangeOrNil(selection: NSRange) -> NSRange? {
        if selection.location == 0 {
            return nil
        }
        let previousLineEnd = NSRange(location: selection.location-1, length: 0)
        return getLineRange(string: string as NSString, selectedRange: previousLineEnd)
    }
}
