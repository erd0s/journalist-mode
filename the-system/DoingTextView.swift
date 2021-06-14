import Cocoa
import Carbon
import AppKit

class DoingContent {
    var lines: [DoingLine] = []
    
    func addLine(line: DoingLine) {
        lines.append(line)
    }
    
    func isTopOfStack(lineNumber: Int) -> Bool {
        for index in stride(from: lines.count-1, to: lineNumber+1, by: -1) {
            if lines[index].complete == false {
                return false
            }
        }
        
        return !lines[lineNumber].complete
    }
    
    // Returns the line number for the top of the stack, -1 if there is no incomplete task in stack
    func topOfStack() -> Int {
        for index in stride(from: lines.count-1, to: -1, by: -1) {
            if lines[index].complete == false {
                return index
            }
        }
        
        return -1
    }
    
    func deleteLastLine() {
        lines.popLast()
    }
}

struct DoingLine {
    var indent: Int
    var complete: Bool
}

class DoingTextView: TextView {
    let indentWidth = 15
    var content: DoingContent = DoingContent()
    
    var observation: NSKeyValueObservation?
    
    required init?(coder: NSCoder) {
        content.addLine(line: DoingLine(indent: 0, complete: false))
        super.init(coder: coder)
    }
    
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
        // Check if the last line is empty (don't let them have a blank line in the doing view)
        if isLastLineEmpty() {
            return
        }
        
        // MARK: - NEW
        
        // Get the deepest incomplete line and indent from there
        let deepestIncomplete = content.lines.reduce(-1) { (currentResult, line) -> Int in
            if !line.complete && line.indent > currentResult {
                return line.indent
            } else {
                return currentResult
            }
        }
        let indent = (deepestIncomplete + 1) * 15
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        style.firstLineHeadIndent = CGFloat(indent)
        style.headIndent = CGFloat(indent)
        
        content.addLine(line: DoingLine(indent: deepestIncomplete + 1, complete: false))
        
        // Move to the end of the doc
        setSelectedRange(NSRange(location: textStorage!.length, length: 0))
        
        super.keyDown(with: event)
        typingAttributes = [NSAttributedString.Key.paragraphStyle: style]
    }
    
    func completeTask() {
        // If they're completing an empty line, delete that line
        if isLastLineEmpty() {
            content.deleteLastLine()
            deleteLastLine()
            
            // Move to the top of the stack
            setSelectedRange(getEndOfLine(forLineNumber: content.topOfStack()))
            return
        }
        
        let lineNumber = getLineNumber()
        let currentLine = content.lines[lineNumber]
        
        if content.isTopOfStack(lineNumber: lineNumber) && !currentLine.complete {
            // They're at the last task in the stack and it's not yet completed
            
            // Mark this line done
            let lineRange = getLineRange(forLineNumber: lineNumber)
            
            content.lines[getLineNumber()].complete = true
            
            textStorage?.addAttribute(.strikethroughStyle, value: 2, range: lineRange)
        }
        
        // Move the cursor to the top of the stack
        var topOfStack = content.topOfStack()
        if topOfStack == -1 {
            topOfStack = 0
        }
        let endOfLine = getEndOfLine(forLineNumber: topOfStack)
        setSelectedRange(endOfLine)
    }
    
    // MARK: - Utility functions
    
    // Make the content object match what we currently have in textStorage, called after file is loaded
    func updateContent(fromAttributedString attributedString: NSMutableAttributedString) {
        let doingLines = attributedString.getAllLinesAhead(startingAt: 0)
        content = DoingContent()
        doingLines.forEach { (attributedString) in
            // Get indent
            let indentLevel = attributedString.getLineIndent() / 15
            let completed: Bool = attributedString.isLineComplete()
            
            content.addLine(line: DoingLine(indent: Int(indentLevel), complete: completed))
        }
    }
    
    func isLastLineEmpty() -> Bool {
        let lines = NSString(string: String(textStorage!.string)).components(separatedBy: "\n")
        let lastLine = lines[lines.count-1].replacingOccurrences(of: " ", with: "")
        if lastLine.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    func deleteLastLine() {
        let lines = NSString(string: String(textStorage!.string)).components(separatedBy: "\n")
        let endOfSecondLastLine = getEndOfLine(forLineNumber: lines.count-2)
        textStorage?.setAttributedString((textStorage?.attributedSubstring(from: NSRange(location: 0, length: endOfSecondLastLine.location)))!)
    }
}
