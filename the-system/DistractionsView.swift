import Cocoa

@IBDesignable
class DistractionsView: NSView
{
    @IBOutlet var topView: NSView!
    @IBOutlet var distractionsTextView: TextView!
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let newNib = NSNib(nibNamed: "DistractionsView", bundle: Bundle(for: type(of: self)))
        newNib!.instantiate(withOwner: self, topLevelObjects: nil)
        var newConstraints: [NSLayoutConstraint] = []
        
        for oldConstraint in topView.constraints {
            let firstItem = oldConstraint.firstItem === topView ? self : oldConstraint.firstItem
            let secondItem = oldConstraint.secondItem === topView ? self : oldConstraint.secondItem
            
            newConstraints.append(
                NSLayoutConstraint(item: firstItem as Any,
                                   attribute: oldConstraint.firstAttribute,
                                   relatedBy: oldConstraint.relation,
                                   toItem: secondItem,
                                   attribute: oldConstraint.secondAttribute,
                                   multiplier: oldConstraint.multiplier,
                                   constant: oldConstraint.constant)
            )
        }
        
        for newView in topView.subviews {
            self.addSubview(newView)
        }
        self.addConstraints(newConstraints)
        wantsLayer = true
        layer?.backgroundColor = CGColor.white
    }
}
