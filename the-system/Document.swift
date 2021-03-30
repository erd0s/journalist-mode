import Cocoa

class Document: NSDocument {
    
    @objc var content = Content(doing: "", todo: "", distractions: "Keyboard shortcuts:\n\nDoing: CMD+SHIFT+J\nTodo: CMD+SHIFT+K\nDistractions: CMD+SHIFT+L\nFinish task: SHIFT+ENTER")
    var doingWindowController: DoingWindowController!
    var todoWindowController: TodoWindowController!
    var distractionsWindowController: DistractionsWindowController!
    let separator = "\n\n################################################################\n\n"

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return false
    }
    
    func enableWindow(type: SystemPart) {
        doingWindowController.showWindow(nil)
        todoWindowController.showWindow(nil)
        distractionsWindowController.showWindow(nil)
        
        switch type {
        case .Doing:
            doingWindowController.showWindow(nil)
        case .Todo:
            todoWindowController.showWindow(nil)
        case .Distractions:
            distractionsWindowController.showWindow(nil)
        }
    }

    override func makeWindowControllers() {
        doingWindowController = makeController(identifier: "Doing Window Controller") as? DoingWindowController
        todoWindowController = makeController(identifier: "Todo Window Controller") as? TodoWindowController
        distractionsWindowController = makeController(identifier: "Distractions Window Controller") as? DistractionsWindowController
    }
    
    func makeController(identifier: String) -> NSWindowController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(identifier)) as! NSWindowController
        self.addWindowController(windowController)
        windowController.contentViewController?.representedObject = content
        return windowController
    }
    
    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        let doingLines = ((doingWindowController.contentViewController as! DoingViewController).textView as TextView).getAllLinesAhead(startingAt: 0)
        var doingAsciiLines: [String] = []
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
        var doingString = doingAsciiLines.joined(separator: "\n")
        
        // Get the todo string
        var todoAsciiLines: [String] = []
        let todoLines = ((todoWindowController.contentViewController as! TodoViewController).textView as TextView).getAllLinesAhead(startingAt: 0)
        todoLines.forEach { (attributedString) in
            if attributedString.isLineComplete() {
                todoAsciiLines.append("~~" + attributedString.string + "~~")
            } else {
                todoAsciiLines.append(attributedString.string)
            }
        }
        var todoString = todoAsciiLines.joined(separator: "\n")
        
        // Get the distractions string
        var distractionsString = ((distractionsWindowController.contentViewController as! DistractionsViewController).textView as TextView).string
        
        let fullString = doingString + separator + todoString + separator + distractionsString
        
        return fullString.data(using: .utf8)!
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        let fullString = String(bytes: data, encoding: .utf8)!
        let sections = fullString.components(separatedBy: separator)
        
        // Doing string
        let doingLines = sections[0].split(separator: "\n")
        doingLines.forEach { (string) in
            // Get the number of spaces at the start of the line
            let numSpaces = String(string).numSpacesAtStart()
            
            // Strip the starting bit
            let trimmed = String(string).dropFirst(numSpaces + 2)
            
            // Strip the starting
            if trimmed.prefix(2) == "~~" && trimmed.suffix(2) == "~~" {
                // It's completed
                
            } else {
                // Not completed
            }
        }
        
        // Todo string
        let todoLines = sections[1].split(separator: "\n")
        
        content.read(from: data)
    }
}
