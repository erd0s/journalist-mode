import Cocoa
import OSLog

class SingleViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet var doingTextView: DoingTextView!
    @IBOutlet var todoTextView: TodoTextView!
    @IBOutlet var distractionsTextView: TextView!
    
    @IBOutlet weak var doingScrollView: NSScrollView!
    @IBOutlet weak var todoScrollView: NSScrollView!
    @IBOutlet weak var distractionsScrollView: NSScrollView!
    @IBOutlet weak var distractionsClip: ClipView!
    @IBOutlet weak var todoClip: ClipView!
    @IBOutlet weak var doingClip: ClipView!
    var observation: NSKeyValueObservation?
    let defaultLog = Logger()
    
    var doingUndo: UndoManager = UndoManager()
    var todoUndo: UndoManager = UndoManager()
    var distractionsUndo: UndoManager = UndoManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observation = observe(\.representedObject, options: .new) { (object, change) in
            self.doingTextView.updateContent(fromAttributedString: (change.newValue as? Content)!.doingString)
        }
    }
    
    override func viewDidAppear() {
        defaultLog.debug("SingleViewController::viewWillAppear invoked")
        self.doingTextView.lookForTimers()
        
        doingClip.setFrameSize(doingScrollView.bounds.size)
        doingClip.setFrameOrigin(NSPoint(x: 0, y: 0))
        todoClip.setFrameSize(todoScrollView.bounds.size)
        todoClip.setFrameOrigin(NSPoint(x: 0, y: 0))
        distractionsClip.setFrameSize(distractionsScrollView.bounds.size)
        distractionsClip.setFrameOrigin(NSPoint(x: 0, y: 0))
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
    
    weak var document: Document? {
        if let docRepresentedObject = representedObject as? Document {
            return docRepresentedObject
        }
        return nil
    }

    // MARK: - NSTextViewDelegate

    func textDidBeginEditing(_ notification: Notification) {
        document?.objectDidBeginEditing(self)
    }

    func textDidEndEditing(_ notification: Notification) {
        document?.objectDidEndEditing(self)
    }
    
    func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
        // Extract out the time from the link
        if let timeString = link as? String {
            let seconds = timeString.secondsForTimeString()
            let itemTitle = "testing 123"
            Countdown.shared.startCountdown(seconds: seconds, itemName: itemTitle)
        }
        return true
    }
    
    func undoManager(for view: NSTextView) -> UndoManager? {
        if view is DoingTextView {
            return doingUndo
        }
        if view is TodoTextView {
            return todoUndo
        }
        else {
            return distractionsUndo
        }
    }
    
    func textDidChange(_ notification: Notification) {
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = 10
        doingTextView.defaultParagraphStyle = style
        todoTextView.defaultParagraphStyle = style
        distractionsTextView.defaultParagraphStyle = style
        doingTextView.textStorage?.font = NSFont(name: "SF Pro Text", size: 14)
        todoTextView.textStorage?.font = NSFont(name: "SF Pro Text", size: 14)
        distractionsTextView.textStorage?.font = NSFont(name: "SF Pro Text", size: 14)
        if notification.object is DoingTextView {
            doingTextView.textChanged(
            )
        }
        print(notification)
    }
    
    func textView(_ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int) -> NSMenu? {
        if view is DoingTextView {
            let complete = NSMenuItem(title: "Complete Task (⇧⏎)", action: #selector(clickedComplete(sender:)), keyEquivalent: "")
            menu.insertItem(complete, at: 0)
        }
        if view is TodoTextView {
            let complete = NSMenuItem(title: "Mark complete (⇧⏎)", action: #selector(clickedTodoComplete(sender:)), keyEquivalent: "")
            let uncomplete = NSMenuItem(title: "Mark not complete (⌘⇧X)", action: #selector(clickedTodoNotComplete(sender:)), keyEquivalent: "")
            menu.insertItem(complete, at: 0)
            menu.insertItem(uncomplete, at: 1)
            menu.insertItem(NSMenuItem.separator(), at: 2)
        }
        return menu
    }
    
    @objc func clickedComplete(sender: NSMenuItem) {
        doingTextView.completeTask()
    }
    
    @objc func clickedTodoComplete(sender: Any) {
        todoTextView.markDone()
    }
    
    @objc func clickedTodoNotComplete(sender: Any) {
        todoTextView.unmarkDone()
    }

    @IBAction func menuDoing(_ sender: Any) {
        selectPart(type: .Doing)
    }
    
    @IBAction func menuTodo(_ sender: Any) {
        selectPart(type: .Todo)
    }
    
    @IBAction func menuDistractions(_ sender: Any) {
        selectPart(type: .Distractions)
    }
    
    @IBAction func menuHelp(_ sender: Any) {
        let url = URL(string:"https://medium.com/@dirkdirk/how-i-get-things-done-journalist-mode-b861e9c088f4")!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func keyboardShortcurts(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = "Global Hotkeys:\nDoing - ⌘⇧J\nTodo - ⌘⇧K\nDistractions - ⌘⇧L\nHide windows - Esc\n\nDoing:\nNew task - return\nComplete task - ⇧ return\n\nTodo: Complete task - ⇧ return\nMark incomplete - ⌘⇧X"
        alert.runModal()
    }
}
