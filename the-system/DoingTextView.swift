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
        // Check if we need to start a new top level task
        if areAllTasksComplete() {
            // New top level item
            setSelectedRange(NSRange(location: string.count, length: 0))
            
            let style = NSMutableParagraphStyle()
            style.firstLineHeadIndent = 0
            style.headIndent = 0
            typingAttributes = [NSAttributedString.Key.paragraphStyle: style]
            super.keyDown(with: event)
            return
        }
        
        let currentLineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
        
        let linesAhead = getAllLinesAfterCurrent()

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
            
            let indent: CGFloat = attributedString().attributedSubstring(from: topOfStack).getLineIndent() + 15.0
            style.firstLineHeadIndent = indent
            style.headIndent = indent
            typingAttributes = [NSAttributedString.Key.paragraphStyle: style]
            
            setSelectedRange(NSRange(location: topOfStack.location + topOfStack.length, length: 0))
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
        let currentLineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
        
        if isTopOfStack() && !isLineCompleted(range: currentLineRange) {
            // They're at the last task in the stack and it's not yet completed
            
            // Mark this line done
            let lineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
            textStorage?.addAttribute(.strikethroughStyle, value: 2, range: lineRange)
        }
        
        // Move the cursor to the top of the stack
        let topOfStack = getTopOfStackRange()
        setSelectedRange(NSRange(location: topOfStack.location + topOfStack.length, length: 0))
    }
}
