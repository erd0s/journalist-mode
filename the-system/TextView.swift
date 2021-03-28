import Cocoa
import Carbon

class TextView: NSTextView {
    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_Escape:
            NSRunningApplication.current.hide()
        default:
            super.keyDown(with: event)
        }
    }
    
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
    
    func getLineIndent(attributedString: NSAttributedString) -> CGFloat {
        var currentIndent: CGFloat = 0
        attributedString.enumerateAttribute(.paragraphStyle, in: NSRange(location: 0, length: attributedString.length), options: [], using: { (value, range, _) in
            currentIndent = (value as! NSParagraphStyle).headIndent
        })
        return currentIndent
    }
    
    func getAllLinesAhead() -> [NSAttributedString] {
        let totalStringLength = string.count
        var lines: [NSAttributedString] = []
        var searchRange = NSRange(location: selectedRange().location, length: totalStringLength - selectedRange().location)

        let theString = string as NSString
        var foundRange = theString.rangeOfCharacter(from: ["\n"], range: searchRange)
        while foundRange.location != Int.max {
            lines.append(attributedString().attributedSubstring(from: foundRange))
            
            // Check if this was the last line in the document
            if foundRange.location + foundRange.length >= totalStringLength {
                break
            }
            
            let endOfRange = foundRange.location + foundRange.length
            searchRange = NSRange(location: endOfRange, length: totalStringLength - endOfRange)
            foundRange = theString.rangeOfCharacter(from: ["\n"], range: searchRange)
        }
        
        return lines
    }
    
    // Checks if all the attributed strings passed in are already marked as complete (strikethrough)
    func areAllLinesComplete(lines: [NSAttributedString]) -> Bool {
        return lines.allSatisfy { (attributedString) -> Bool in
            isLineComplete(line: attributedString)
        }
    }
    
    func isLineComplete(line: NSAttributedString) -> Bool {
        var found = false
        line.enumerateAttribute(.strikethroughStyle, in: NSRange(location: 0, length: line.length)) { (value, range, _) in
            if value != nil && (value as? Int) != 0 {
                found = true
            }
        }
        return found
    }
    
    // Checks if the current line is incomplete, and any later lines are complete
    func isTopOfStack() -> Bool {
        let currentLine = getCurrentLine()
        if isLineComplete(line: currentLine) {
            return false
        }
        
        return areAllLinesComplete(lines: getAllLinesAhead())
    }
    
    // Find the range of the currently in progress task
    func getTopOfStackRange() -> NSRange {
        var nextNewline = (string as NSString).rangeOfCharacter(from: ["\n"], options: .backwards, range: NSRange(location: 0, length: string.count))
        var lineStart = nextNewline.location
        var lineEnd = string.count
        
        if nextNewline.location == Int.max {
            return NSRange(location: 0, length: string.count)
        }
        
        while nextNewline.location != Int.max {
            let currentRange = NSRange(location: lineStart, length: lineEnd - lineStart)
            
            let line = attributedString().attributedSubstring(from: currentRange)
            if !isLineComplete(line: line) {
                return currentRange
            }
            
            nextNewline = (string as NSString).rangeOfCharacter(from: ["\n"], options: .backwards, range: NSRange(location: 0, length: lineStart - 1))
            lineEnd = lineStart - 1
            lineStart = nextNewline.location
            print(String(lineStart) + ", " + String(lineEnd))
        }
        
        return NSRange(location: 0, length: 0)
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
}
