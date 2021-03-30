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
    
}
