import Cocoa

class Content: NSObject {
    @objc dynamic var doingString = "Doing temp"
    @objc dynamic var todoString = "Todo temp"
    @objc dynamic var distractionsString = "Distractions temp"
    
    public init(doing: String, todo: String, distractions: String) {
        self.doingString = doing
        self.todoString = todo
        self.distractionsString = distractions
    }
    
    let separator = "\n\n################################################################\n\n"
    
    func read(from data: Data) {
        let contentString = String(bytes: data, encoding: .utf8)!
        let components = contentString.components(separatedBy: separator)
        doingString = components.count > 0 ? components[0] : ""
        todoString = components.count > 1 ? components[1] : ""
        distractionsString = components.count > 2 ? components[2] : ""
    }
    
    func data() -> Data? {
        let componentsString = doingString + separator + todoString + separator + distractionsString
        return componentsString.data(using: .utf8)
    }
}
