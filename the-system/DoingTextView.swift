import Cocoa
import Carbon
import AppKit

class DoingTextView: TextView {
    let indentWidth = 15
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == kVK_Return && event.modifierFlags.contains(NSEvent.ModifierFlags.shift) {
            completeTask()
        } else if event.keyCode == kVK_Return {
            newTask(with: event)
        } else {
            super.keyDown(with: event)
        }
    }
    
    func newTask(with event: NSEvent) {
        var currentLineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
        
        var linesAhead = getAllLinesAhead()

        let style = NSMutableParagraphStyle()
        
        if linesAhead.count > 0 && areAllLinesComplete(lines: linesAhead) && !isLineCompleted(range: currentLineRange) {
            // They're at the last task in the stack and there's other completed tasks further down the page
            
            let indent: CGFloat = getCurrentLineIndent() + 15.0
            
            // Skipping to the end of the document
            setSelectedRange(NSRange(location: string.count, length: 0))
            style.firstLineHeadIndent = indent
            style.headIndent = indent
            typingAttributes = [NSAttributedString.Key.paragraphStyle: style]
            super.keyDown(with: event)
        } else if linesAhead.count > 0 {
            // They're not at the last task in the stack, find that position and move them there
            
            // Skip to the top of the stack
            let topOfStack = getTopOfStackRange()
            
            let indent: CGFloat = getLineIndent(attributedString: attributedString().attributedSubstring(from: topOfStack)) + 15.0
            style.firstLineHeadIndent = indent
            style.headIndent = indent
            typingAttributes = [NSAttributedString.Key.paragraphStyle: style]
            
            setSelectedRange(NSRange(location: topOfStack.location + topOfStack.length + 1, length: 0))
        } else {
            // They're at the last position in the stack and there's no tasks further down the page
            
            let indent: CGFloat = getCurrentLineIndent() + 15.0
            style.firstLineHeadIndent = indent
            style.headIndent = indent
            typingAttributes = [NSAttributedString.Key.paragraphStyle: style]
            
            super.keyDown(with: event)
        }
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
}
