import Cocoa
import Sentry

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var documentController: DocumentController?
    var foundRecentDocUrl: URL?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        documentController!.setupHotkeys()
        SentrySDK.start { options in
            options.dsn = "https://8bdeee1fc0d24611b618baf590dd0d00@o1164403.ingest.sentry.io/6253504"
            options.debug = true // Enabled debug when first installing is always helpful

            // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
            // We recommend adjusting this value in production.
            options.tracesSampleRate = 1.0
        }
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        documentController = DocumentController()
    }
    
    func applicationShouldTerminate(_ sender: NSApplication)-> NSApplication.TerminateReply {
        return .terminateNow
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        // Get most recent documents
        let docController = NSDocumentController.shared
        let documents = docController.recentDocumentURLs

        if documents.count > 0 {
            foundRecentDocUrl = documents[0]
            NSDocumentController.shared.openDocument(
                withContentsOf: foundRecentDocUrl!,
                display: true,
                completionHandler: { (document: NSDocument?, documentWasAlreadyOpen: Bool, err: Error?) in
                if err != nil {
                    try? self.documentController!.openUntitledDocumentAndDisplay(true)
                }
            })
            return false
        }
        return true
    }
    
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
}
