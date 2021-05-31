//
//  SingleViewController.swift
//  the-system
//
//  Created by Dirk on 21/05/2021.
//

import Cocoa

class SingleViewController: NSViewController {
    
    @IBOutlet weak var doingView: DoingView!
    @IBOutlet weak var todoView: TodoView!
    @IBOutlet weak var distractionsView: DistractionsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func selectPart(type: SystemPart) {
        switch type {
        case .Doing:
            doingView.window?.makeFirstResponder(doingView.doingTextView)
        case .Todo:
            todoView.window?.makeFirstResponder(todoView.todoTextView)
        case .Distractions:
            distractionsView.window?.makeFirstResponder(distractionsView.distractionsTextView)
        }
    }
}
