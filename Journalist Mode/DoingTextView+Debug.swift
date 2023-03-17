import Foundation

extension DoingTextView {
    func debugIndent() {
        for line in content.lines {
            let padding = "".padding(toLength: line.indent, withPad: " ", startingAt: 0)
            let status = line.complete ? "-" : "O"
            print(padding + status)
        }
    }
    
    func debugTypingAttributes() {
        print("=============== TYPING ATTRIBUTES ===============")
        typingAttributes.forEach { (key: NSAttributedString.Key, value: Any) in
            print("\(key): \(value)")
        }
    }
}
