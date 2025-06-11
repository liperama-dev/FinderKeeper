import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Check if the extension is enabled
        let finderSync = FIFinderSyncController.default()
        if !finderSync.isExtensionEnabled {
            // The extension is not enabled, show instructions
            let alert = NSAlert()
            alert.messageText = "Enable FinderContextualUtilities in System Preferences"
            alert.informativeText = "Please enable the FinderContextualUtilities extension in System Preferences > Extensions > Finder Extensions"
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Quit")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.extensions?Finder")!)
            }
            
            NSApp.terminate(nil)
        } else {
            // Extension is enabled, we can quit the app
            NSApp.terminate(nil)
        }
    }
}
