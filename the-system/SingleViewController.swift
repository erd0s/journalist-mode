//
//  SingleViewController.swift
//  the-system
//
//  Created by Dirk on 21/05/2021.
//

import Cocoa

class SingleViewController: NSViewController {
    
    @IBOutlet var doingTextView: DoingTextView!
    @IBOutlet var todoTextView: TodoTextView!
    @IBOutlet var distractionsTextView: TextView!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func selectPart(type: SystemPart) {
        switch type {
        case .Doing:
            doingTextView.window?.makeFirstResponder(doingTextView)
        case .Todo:
            todoTextView.window?.makeFirstResponder(todoTextView)
        case .Distractions:
            distractionsTextView.window?.makeFirstResponder(distractionsTextView)
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Pass down the represented object to all of the child view controllers.
            for child in children {
                child.representedObject = representedObject
            }
        }
    }
}
