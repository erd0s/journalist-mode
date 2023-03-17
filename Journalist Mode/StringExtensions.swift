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
    
    // Parses 5m or 1h style strings and gives back the number of seconds
    func secondsForTimeString() -> Int {
        var copy = self
        let lastLetter = copy.popLast()
        if lastLetter == "m" {
            return (Int(copy) ?? 0) * 60
        } else if lastLetter == "h" {
            return (Int(copy) ?? 0) * 60 * 60
        } else {
            print("unknown suffix on time string")
            return 0
        }
    }
}
