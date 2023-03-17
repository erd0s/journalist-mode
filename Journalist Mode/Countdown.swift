import Cocoa

class Countdown {
    
    static let shared = Countdown()
    
    var secondsLeft: Int = 0
    var currentItemName: String = ""
    
    var timer: Timer?
    
    var statusItem: NSStatusItem?
    
    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: 52.0)
        if let button = statusItem?.button {
            button.action = #selector(togglePopover)
        }
        statusItem?.isVisible = false
    }
    
    func startCountdown(seconds: Int, itemName: String) {
        statusItem?.isVisible = true
        secondsLeft = seconds
        currentItemName = itemName
        
        // Kill existing timer
        if timer != nil {
            timer?.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
        fireTimer()
    }
    
    @objc func fireTimer() {
        statusItem?.button!.image = imageForTime(secondsLeft: secondsLeft)
        secondsLeft = secondsLeft - 1
        
        if secondsLeft < 0 {
            let alert = NSAlert()
            alert.messageText = "Time's up"
            alert.runModal()
            timer?.invalidate()
            NSApplication.shared.activate(ignoringOtherApps: true)
            statusItem?.isVisible = false
        }
    }
    
    func imageForTime(secondsLeft: Int) -> NSImage {
        let mins = String(format: "%02d", Int(floor(Double(secondsLeft)/60.0)))
        let secs = String(format: "%02d", secondsLeft%60)
        let text = "\(mins):\(secs)"
        let font = NSFont.systemFont(ofSize: 14)
        let imageRect = CGRect(x: 0, y: 0, width: 52, height: 22)
        let textRect = CGRect(x: 6, y: 5, width: 52 - 5, height: 22 - 7)
        let textStyle = NSMutableParagraphStyle()
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: NSColor.black,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
        let size = NSSize(width: 52, height: 22)
        let image = NSImage(size: size)
        let rep:NSBitmapImageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSColorSpaceName.calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        image.addRepresentation(rep)
        image.lockFocus()
        image.draw(in: imageRect)
        text.draw(in: textRect, withAttributes: textFontAttributes)
        image.unlockFocus()
        image.isTemplate = true
        return image
    }
    
    @objc func togglePopover() {
        print("ok")
    }
}
