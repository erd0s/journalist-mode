import Cocoa
import Carbon

let defaultFont = NSFont(name: "SF Pro Text", size: 14)

class TextView: NSTextView, NSTextViewDelegate {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textStorage?.font = defaultFont
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        typingAttributes = [NSAttributedString.Key.paragraphStyle: style, .font: NSFont(name: "SF Pro Text", size: 14)]
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
    
    func getLineNumber() -> Int {
        let stringBackwards = NSString(string: String(textStorage!.string.prefix(selectedRange().location)))
        return stringBackwards.components(separatedBy: "\n").count - 1
    }
    
    func getEndOfLine(forLineNumber lineNumber: Int) -> NSRange {
        let lines = NSString(string: String(textStorage!.string)).components(separatedBy: "\n")
        var runningCount = 0
        for index in 0...lineNumber {
            runningCount = runningCount + lines[index].count + 1
        }
        
        // We want just before that last \n
        runningCount = runningCount - 1
        
        return NSRange(location: runningCount, length: 0)
    }
    
    func getLineRange(forLineNumber lineNumber: Int) -> NSRange {
        let lines = NSString(string: String(textStorage!.string)).components(separatedBy: "\n")
        var runningCount = 0
        
        if lineNumber > 0 {
            for index in 0...lineNumber-1 {
                runningCount = runningCount + lines[index].count + 1
            }
        }
        
        return NSRange(location: runningCount, length: lines[lineNumber].count)
    }
}
