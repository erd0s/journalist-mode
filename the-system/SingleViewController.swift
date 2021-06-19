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
    
    var observation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        observation = observe(\.representedObject, options: .new) { (object, change) in
            self.doingTextView.updateContent(fromAttributedString: (change.newValue as? Content)!.doingString)
        }
    }
    
    func selectPart(type: SystemPart) {
        let targetTextView: NSTextView
        switch type {
        case .Doing:
            targetTextView = doingTextView
        case .Todo:
            targetTextView = todoTextView
        case .Distractions:
            targetTextView = distractionsTextView
        }
        targetTextView.window?.makeFirstResponder(targetTextView)
        if let cursorPosition = targetTextView.selectedRanges.first {
            targetTextView.scrollRangeToVisible(NSRange(location: cursorPosition.rangeValue.location, length: 0))
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
