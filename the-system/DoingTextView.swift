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
    var content: DoingContent
    var reflowRequired = false
    
    var observation: NSKeyValueObservation?
    
    required init?(coder: NSCoder) {
        content = DoingContent()
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
    
    override func shouldChangeText(in affectedCharRange: NSRange, replacementString: String?) -> Bool {
        // If they're removing lines of text everything needs to be reshuffled
        if let range = textStorage?.attributedSubstring(from: affectedCharRange).string.rangeOfCharacter(from: .newlines) {
            if !range.isEmpty {
                print("looks like there's an affected newline")
                reflowRequired = true
            }
        }
        return super.shouldChangeText(in: affectedCharRange, replacementString: replacementString)
    }
    
    override func textDidChange(_ notification: Notification) {
        if reflowRequired {
            print("looks like we need to reflow")
            
            // TODO - This functionality could be neater
            // TODO - Lots of duplication going on here, but it's not that complicated
            // Remove any indents that are too indented
            // This should just clean it up so that indents are at most 15px
            var searchStart = 0
            let searchEnd = string.count
            var runningIndent: CGFloat = 0.0
            
            while true {
                let foundNewline = (string as NSString).rangeOfCharacter(from: ["\n"], range: NSRange(location: searchStart, length: searchEnd-searchStart))
                
                if foundNewline.location != Int.max {
                    let lineRange = NSRange(location: searchStart, length: foundNewline.location - searchStart)
                    let line = textStorage?.attributedSubstring(from: lineRange)
                    var indent = line!.getLineIndent()
                    
                    // Is this range more than 15 greater than the previous?
                    if indent > runningIndent + 15 {
                        // Clean it up
                        let newString = NSMutableAttributedString(attributedString: line!)
                        
                        let style = NSMutableParagraphStyle()
                        style.paragraphSpacing = 10
                        style.firstLineHeadIndent = CGFloat(runningIndent + 15)
                        style.headIndent = CGFloat(runningIndent + 15)
                        
                        newString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: newString.length))
                        textStorage?.replaceCharacters(in: lineRange, with: newString)
                        
                        indent = runningIndent + 15
                    }
                    
                    runningIndent = indent
                    
                    searchStart = foundNewline.location+1
                    if searchStart >= searchEnd {
                        break
                    }
                } else {
                    if searchEnd-searchStart > 0 {
                        let lineRange = NSRange(location: searchStart, length: searchEnd-searchStart)
                        let line = textStorage?.attributedSubstring(from: lineRange)
                        let indent = line!.getLineIndent()
                        
                        let newString = NSMutableAttributedString(attributedString: line!)
                        
                        let style = NSMutableParagraphStyle()
                        style.paragraphSpacing = 10
                        style.firstLineHeadIndent = CGFloat(runningIndent + 15)
                        style.headIndent = CGFloat(runningIndent + 15)
                        
                        newString.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: newString.length))
                        textStorage?.replaceCharacters(in: lineRange, with: newString)
                    }
                    break
                }
            }
            
            // Set up Content to match what we have in the textview
            updateContent(fromAttributedString: textStorage!)
                        
            reflowRequired = false
            didChangeText()
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
        style.paragraphSpacing = 10
        style.firstLineHeadIndent = CGFloat(indent)
        style.headIndent = CGFloat(indent)
        
        content.addLine(line: DoingLine(indent: deepestIncomplete + 1, complete: false))
        
        // Move to the end of the doc
        setSelectedRange(NSRange(location: textStorage!.length, length: 0))
        
        super.keyDown(with: event)
        typingAttributes = [NSAttributedString.Key.paragraphStyle: style, .font: NSFont(name: "SF Pro Text", size: 14)]
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
        didChangeText()
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
        
        // When we open a new file the content is empty and this doesn't initialise right, fix it
        if content.lines.count == 0 {
            content.addLine(line: DoingLine(indent: 0, complete: false))
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
