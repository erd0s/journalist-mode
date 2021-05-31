import Cocoa

class Document: NSDocument {
    
    @objc var content = Content(doing: "", todo: "", distractions: "")
    var doingWindowController: DoingWindowController!
    var todoWindowController: TodoWindowController!
    var distractionsWindowController: DistractionsWindowController!
    
    var singleWindowController: SingleWindowController!
    
    let separator = "\n\n################################################################\n\n"

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return false
    }
    
    func enableWindow(type: SystemPart) {
        if (displayType == .Single) {
            // Put the cursor in the correct box
            singleWindowController.selectPart(type: type)
        } else {
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
    }

    override func makeWindowControllers() {
        if (displayType == .Single) {
            singleWindowController = makeController(identifier: "Single Window Controller") as? SingleWindowController
        } else {
            doingWindowController = makeController(identifier: "Doing Window Controller") as? DoingWindowController
            todoWindowController = makeController(identifier: "Todo Window Controller") as? TodoWindowController
            distractionsWindowController = makeController(identifier: "Distractions Window Controller") as? DistractionsWindowController
        }
    }
    
    func makeController(identifier: String) -> NSWindowController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(identifier)) as! NSWindowController
        self.addWindowController(windowController)
        windowController.contentViewController?.representedObject = content
        return windowController
    }
    
    override func data(ofType typeName: String) throws -> Data {
        if (displayType == .Multi) {
            (doingWindowController.contentViewController as! DoingViewController).forceUpdate()
        }
        return content.data()!
    }

    override func read(from data: Data, ofType typeName: String) throws {
        content.read(from: data)
    }
}
