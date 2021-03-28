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
}
