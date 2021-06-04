import Cocoa
import Carbon

let defaultFont = NSFont(name: "SF Pro Text", size: 14)

class TextView: NSTextView, NSTextViewDelegate {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textStorage?.font = defaultFont
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        typingAttributes = [NSAttributedString.Key.paragraphStyle: style]
        delegate = self
    }
    
    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_Escape:
            NSRunningApplication.current.hide()
        default:
            super.keyDown(with: event)
        }
    }
    
    override func paste(_ sender: Any?) {
       pasteAsPlainText(sender)
    }
    
    // MARK: - NSTextDelegate (from NSTextViewDelegate)
    
    func textDidChange(_ notification: Notification) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        defaultParagraphStyle = style
        textStorage?.font = NSFont(name: "SF Pro Text", size: 14)
    }
    
    // MARK: - Custom
    
    func getLineRange(string: NSString, selectedRange: NSRange) -> NSRange {
        // Look backwards from this range for a newline
        let backwards = string.range(of: "\n", options: .backwards, range: NSRange(location: 0, length: selectedRange.location))
        // Make sure we're not at the very first line
        var start: Int
        if backwards.location == Int.max {
            start = 0
        } else {
            start = backwards.location
        }
        
        // Look forwards for a newline
        let forwards = string.rangeOfCharacter(from: ["\n"], range: NSRange(location: selectedRange.location, length: string.length - selectedRange.location))
        var end: Int
        // Make sure there's a newline at the end
        if forwards.location == Int.max {
            // Should be the end of the whole string
            end = string.length
        } else {
            end = forwards.location
        }
            
        return NSRange(location: start, length: end - start)
    }
    
    func getCurrentLineRange() -> NSRange {
        return getLineRange(string: string as NSString, selectedRange: selectedRange())
    }
    
    func getCurrentLine() -> NSAttributedString {
        let currentRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
        return attributedString().attributedSubstring(from: currentRange)
    }
    
    func getCurrentLineIndent() -> CGFloat {
        let currentLineRange = getLineRange(string: string as NSString, selectedRange: selectedRange())
        var currentIndent: CGFloat = 0
        textStorage?.enumerateAttribute(.paragraphStyle, in: currentLineRange, options: [], using: { (value, range, _) in
            currentIndent = (value as! NSParagraphStyle).headIndent
        })
        return currentIndent
    }
    
    func getAllLinesAfterCurrent() -> [NSAttributedString] {
        let currentLineRange = getCurrentLineRange()
        if currentLineRange.location + currentLineRange.length + 1 >= string.count {
            return []
        } else {
            return textStorage!.getAllLinesAhead(startingAt: currentLineRange.location + currentLineRange.length + 1)
        }
    }
    
    func areAllTasksComplete() -> Bool {
        var tasks = string.split(separator: "\n")
        var runningLocation = 0
        var allTasks: [NSAttributedString] = []
        tasks.forEach { (task) in
            allTasks.append(attributedString().attributedSubstring(from: NSRange(location: runningLocation, length: task.count)))
            // Adding an extra one here to make up for the missing \n
            runningLocation = runningLocation + task.count + 1
        }
        return allTasks.allSatisfy { (attributedString) -> Bool in
            return attributedString.isLineComplete()
        }
    }
    
    // Checks if all the attributed strings passed in are already marked as complete (strikethrough)
    func areAllLinesComplete(lines: [NSAttributedString]) -> Bool {
        return lines.allSatisfy { (attributedString) -> Bool in
            return attributedString.isLineComplete()
        }
    }
    
    // Checks if the current line is incomplete, and any later lines are complete
    func isTopOfStack() -> Bool {
        let currentLine = getCurrentLine()
        if currentLine.isLineComplete() {
            return false
        }
        
        return areAllLinesComplete(lines: getAllLinesAfterCurrent())
    }
    
    // Find the range of the currently in progress task
    func getTopOfStackRange() -> NSRange {
        var end = string.count
        var start = 0
        while true {
            let nextNewlineBackwards = getNextNewlineBackwards(from: end)
            let lineRange = NSRange(location: nextNewlineBackwards, length: end-nextNewlineBackwards)
            let line = attributedString().attributedSubstring(from: lineRange)
            if !line.isLineComplete() {
                return lineRange
            } else if nextNewlineBackwards == 0 {
                // Special case: if there's no tasks left return range of (0, 0)
                return NSRange(location: 0, length: 0)
            }
            
            end = nextNewlineBackwards
        }
    }
    
    func getNextNewlineBackwards(from startingAt: Int) -> Int {
        let foundRange = (string as NSString).rangeOfCharacter(from: ["\n"], options: .backwards, range: NSRange(location: 0, length: startingAt))
        if foundRange.location != Int.max {
            return foundRange.location
        } else {
            return 0
        }
    }
    
    func isLineCompleted(range: NSRange) -> Bool {
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
    
    func previousLineRangeOrNil(selection: NSRange) -> NSRange? {
        if selection.location == 0 {
            return nil
        }
        let previousLineEnd = NSRange(location: selection.location-1, length: 0)
        return getLineRange(string: string as NSString, selectedRange: previousLineEnd)
    }
    
    func debug() {
        print("======================== STARTING DEBUG ========================")
        print("Length: " + String(textStorage!.length))
        var currentRange = NSRange()
        var currentPosition = 0
        while true {
            let attrs = textStorage!.attributes(at: currentPosition, longestEffectiveRange: &currentRange, in: NSMakeRange(currentPosition, textStorage!.length - currentPosition))
            let attrNames = attrs.map { (arg0) -> String in
                let (key, value) = arg0
                return String(describing: key.rawValue)
            }.joined(separator: ", ")
            let string1 = attrNames + " for "
            let string2 = String(currentRange.location) + " -> "
            let string3 = String(currentRange.location + currentRange.length)
            print(string1 + string2 + string3)
            if currentRange.location + currentRange.length >= textStorage!.length {
                break
            } else {
                currentPosition = currentRange.location + currentRange.length
            }
        }
    }
}
