import Cocoa

extension NSAttributedString {
    func getLineIndent() -> CGFloat {
        var currentIndent: CGFloat = 0
        enumerateAttribute(.paragraphStyle, in: NSRange(location: 0, length: length), options: [], using: { (value, range, _) in
            currentIndent = (value as! NSParagraphStyle).headIndent
        })
        return currentIndent
    }
    
    func isLineComplete() -> Bool {
        var found = false
        enumerateAttribute(.strikethroughStyle, in: NSRange(location: 0, length: length)) { (value, range, _) in
            if value != nil && (value as? Int) != 0 {
                found = true
            }
        }
        return found
    }

    func getAllLinesAhead(startingAt: Int) -> [NSAttributedString] {
        var searchStart = startingAt
        var searchEnd = string.count
        
        var lines: [NSAttributedString] = []
        while true {
            let foundNewline = (string as NSString).rangeOfCharacter(from: ["\n"], range: NSRange(location: searchStart, length: searchEnd-searchStart))
            
            if foundNewline.location != Int.max {
                lines.append(attributedSubstring(from: NSRange(location: searchStart, length: foundNewline.location - searchStart)))
                
                searchStart = foundNewline.location+1
                if searchStart >= searchEnd {
                    break
                }
            } else {
                // Add in the last line
                if searchEnd-searchStart > 0 {
                    lines.append(attributedSubstring(from: NSRange(location: searchStart, length: searchEnd-searchStart)))
                }
                break
            }
        }
        return lines
    }
}
