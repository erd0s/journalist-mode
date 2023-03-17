import Cocoa
import OSLog

class Document: NSDocument {
    
    @objc var content = Content(doing: "", todo: "", distractions: "")
    let defaultLog = Logger()
    
    var singleWindowController: SingleWindowController!
    
    let separator = "\n\n################################################################\n\n"

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        // TODO - Come back to this one when there's
        // no bugs that can fuck up the document
        return false
    }
    
    func enableWindow(type: SystemPart) {
        // Put the cursor in the correct box
        defaultLog.debug("Document::enableWindow invoked")
        singleWindowController.selectPart(type: type)
    }

    override func makeWindowControllers() {
        singleWindowController = makeController(identifier: "Single Window Controller") as? SingleWindowController
    }
    
    func makeController(identifier: String) -> NSWindowController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(identifier)) as! NSWindowController
        self.addWindowController(windowController)
        windowController.contentViewController?.representedObject = content
        return windowController
    }
    
    override func data(ofType typeName: String) throws -> Data {
        // TODO - Maybe we need this?
        // (doingWindowController.contentViewController as! DoingViewController).forceUpdate()
        return content.data()!
    }

    override func read(from data: Data, ofType typeName: String) throws {
        content.read(from: data)
    }
}
