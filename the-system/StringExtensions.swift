import Cocoa

extension String {
    func numSpacesAtStart() -> Int {
        var numSpaces = 0
        let regex = try! NSRegularExpression(pattern: "^ +")
        // Get the number of spaces at the start of the line
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: count))
        regex.enumerateMatches(in: self, options: [], range: NSRange(location: 0, length: count)) { (match, _, stop) in
            if let m = match {
                numSpaces = m.range.length
            }
            
        }
        return numSpaces
    }
}
