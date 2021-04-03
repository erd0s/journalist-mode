import Cocoa

class DoingViewController: NSViewController {

    @IBOutlet var textView: DoingTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func forceUpdate() {
        (representedObject as! Content).doingString = NSMutableAttributedString(attributedString: textView.attributedString())
    }
}