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
        let currentLineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
        
        // Check if the current line is empty (don't let them have a blank line in the doing view)
        if (currentLineRange.location + 1 >= string.count) {
            return
        }
        
        // Check if we need to start a new top level task
        if areAllTasksComplete() {
            // New top level item
            setSelectedRange(NSRange(location: string.count, length: 0))
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 10
            style.firstLineHeadIndent = 0
            style.headIndent = 0
            typingAttributes = [NSAttributedString.Key.paragraphStyle: style]
            super.keyDown(with: event)
            return
        }
        
        let linesAhead = getAllLinesAfterCurrent()

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        
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
        let currentLineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
        
        // TODO: - This should be changed with something that DELETES any trailing empty lines, so that when they
        // manually move their cursor around those last lines are also deleted
        // If they're completing an empty line, delete that line
        if (currentLineRange.location + 1 >= string.count) {
            textStorage?.setAttributedString((textStorage?.attributedSubstring(from: NSRange(location: 0, length: textStorage!.length-1)))!)
        }
        
        if isTopOfStack() && !isLineCompleted(range: currentLineRange) {
            // They're at the last task in the stack and it's not yet completed
            
            // Mark this line done
            let lineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
            textStorage?.addAttribute(.strikethroughStyle, value: 2, range: lineRange)
        }
        
        // Move the cursor to the top of the stack
        let topOfStack = getTopOfStackRange()
        textStorage?.setAttributedString((textStorage?.attributedSubstring(from: NSRange(location: 0, length: textStorage!.length)))!)
        setSelectedRange(NSRange(location: topOfStack.location + topOfStack.length, length: 0))
    }
    
}
