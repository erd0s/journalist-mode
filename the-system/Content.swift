import Cocoa

class Content: NSObject {
    @objc dynamic var doingString: NSMutableAttributedString = NSMutableAttributedString(string: "Doing temp")
    @objc dynamic var todoString: NSMutableAttributedString = NSMutableAttributedString(string: "Todo temp")
    @objc dynamic var distractionsString: NSMutableAttributedString = NSMutableAttributedString(string: "Distractions temp")
    
    public init(doing: String, todo: String, distractions: String) {
        self.doingString = NSMutableAttributedString(string: doing)
        self.todoString = NSMutableAttributedString(string: todo)
        self.distractionsString = NSMutableAttributedString(string: distractions)
    }
    
    let separator = "\n\n################################################################\n\n"
    
    func read(from data: Data) {
        let fullString = String(bytes: data, encoding: .utf8)!
        let sections = fullString.components(separatedBy: separator)

        var doingAttributedStrings: [NSMutableAttributedString] = []

        // Doing string
        let doingLines = sections[0].split(separator: "\n")
        doingLines.forEach { (string) in
            // Get the number of spaces at the start of the line
            let numSpaces = String(string).numSpacesAtStart()

            // Strip the starting bit
            var trimmed = String(string).dropFirst(numSpaces + 2)

            // Strip the starting
            var attributedString: NSMutableAttributedString
            if trimmed.prefix(2) == "~~" && trimmed.suffix(2) == "~~" {
                // It's completed
                trimmed.removeLast(2)
                trimmed.removeFirst(2)
                attributedString = NSMutableAttributedString(string: String(trimmed), attributes: [NSAttributedString.Key.strikethroughStyle: 2])
            } else {
                // Not completed
                attributedString = NSMutableAttributedString(string: String(trimmed))
            }

            // Deal with the indent
            let indentSize = CGFloat(numSpaces/4 * 15)
            let indent = NSMutableParagraphStyle()
            indent.headIndent = indentSize
            indent.firstLineHeadIndent = indentSize
            indent.paragraphSpacing = 10
            
            let length = NSRange(location: 0, length: trimmed.count)
            attributedString.addAttribute(.font, value: defaultFont, range: length)
            attributedString.addAttribute(.paragraphStyle, value: indent, range: length)
            doingAttributedStrings.append(attributedString)
        }
        doingString.append(doingAttributedStrings.joined(with: "\n"))

        // MARK: - Todo string
        
        var todoAttributedStrings: [NSMutableAttributedString] = []
        let todoLines = sections[1].split(separator: "\n")
        todoLines.forEach { (line) in
            var string = line
            
            // Strip the starting
            var attributedString: NSMutableAttributedString
            if string.prefix(2) == "~~" && string.suffix(2) == "~~" {
                // It's completed
                string.removeLast(2)
                string.removeFirst(2)
                attributedString = NSMutableAttributedString(string: String(string), attributes: [NSAttributedString.Key.strikethroughStyle: 2])
            } else {
                // Not completed
                attributedString = NSMutableAttributedString(string: String(string))
            }
            
            let para = NSMutableParagraphStyle()
            para.paragraphSpacing = 10
            let length = NSRange(location: 0, length: string.count)
            attributedString.addAttribute(.font, value: defaultFont, range: length)
            attributedString.addAttribute(.paragraphStyle, value: para, range: length)
            todoAttributedStrings.append(attributedString)
        }
        todoString.append(todoAttributedStrings.joined(with: "\n"))
        
        let defaultParagraphStyle = NSMutableParagraphStyle()
        defaultParagraphStyle.paragraphSpacing = 10
        
        // MARK: - Distractions
        
        let distractionsAttributedString = NSMutableAttributedString(string: sections[2])
        let distractionsRange = NSRange(location: 0, length: distractionsAttributedString.length)
        distractionsAttributedString.addAttribute(.font, value: defaultFont, range: distractionsRange)
        distractionsAttributedString.addAttribute(.paragraphStyle, value: defaultParagraphStyle, range: distractionsRange)
        distractionsString.append(distractionsAttributedString)
    }
    
    func data() -> Data? {
        let doingLines = doingString.getAllLinesAhead(startingAt: 0)
        var doingAsciiLines: [String] = []
        doingString.enumerateAttributes(in: NSRange(location: 0, length: doingString.length), options: []) { (attributes, range, _) in
            print(attributes)
        }
        doingLines.forEach { (attributedString) in
            // Get indent
            let indentLevel = attributedString.getLineIndent() / 15
            let completed: Bool = attributedString.isLineComplete()
            
            let leftPadding = "".padding(toLength: Int(indentLevel)*4, withPad: " ", startingAt: 0)
            if completed {
                doingAsciiLines.append(leftPadding + "- ~~" + attributedString.string + "~~")
            } else {
                doingAsciiLines.append(leftPadding + "- " + attributedString.string)
            }
        }
        var finalDoingString = doingAsciiLines.joined(separator: "\n")
        
        // Get the todo string
        var todoAsciiLines: [String] = []
        let todoLines = todoString.getAllLinesAhead(startingAt: 0)
        todoLines.forEach { (attributedString) in
            if attributedString.isLineComplete() {
                todoAsciiLines.append("~~" + attributedString.string + "~~")
            } else {
                todoAsciiLines.append(attributedString.string)
            }
        }
        var finalTodoString = todoAsciiLines.joined(separator: "\n")
        
        // Get the distractions string
        var finalDistractionsString = distractionsString.string
        
        let fullString = finalDoingString + separator + finalTodoString + separator + finalDistractionsString
        
        return fullString.data(using: .utf8)!
    }
}
