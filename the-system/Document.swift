//
//  Document.swift
//  the-system
//
//  Created by Dirk on 28/02/2021.
//

import Cocoa

class Document: NSDocument {
    
    @objc var content = Content(doing: "", todo: "", distractions: "")
    var doingWindowController: DoingWindowController!
    var todoWindowController: TodoWindowController!
    var distractionsWindowController: DistractionsWindowController!

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
        return content.data()!
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        content.read(from: data)
    }
}
