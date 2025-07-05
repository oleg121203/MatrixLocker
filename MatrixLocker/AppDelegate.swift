import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var lockScreenWindowController: NSWindowController?
    let activityMonitor = ActivityMonitor()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Configure the observer for user inactivity
        NotificationCenter.default.addObserver(self, selector: #selector(showLockScreen), name: .userDidBecomeInactive, object: nil)
        
        // Configure observer for settings changes
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: .settingsDidChange, object: nil)
        
        // Start monitoring user activity with the saved interval (only if automatic lock is enabled)
        if UserSettings.shared.enableAutomaticLock {
            activityMonitor.startMonitoring(inactivityInterval: UserSettings.shared.inactivityTimeout)
            print("MatrixLocker launched. Activity monitoring started with \(UserSettings.shared.inactivityTimeout) seconds limit.")
        } else {
            print("MatrixLocker launched. Activity monitoring disabled (automatic lock is off).")
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up when the app closes
        activityMonitor.stopMonitoring()
        NotificationCenter.default.removeObserver(self)
    }
    
    // This function ensures the app window re-opens when the dock icon is clicked
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows {
                if window.isMiniaturized {
                    window.deminiaturize(sender)
                } else {
                    window.makeKeyAndOrderFront(sender)
                }
            }
        }
        return true
    }

    @objc func showLockScreen() {
        // Prevent showing multiple lock screens
        guard lockScreenWindowController == nil else { return }

        print("User has exceeded activity time limit. Presenting lock screen.")
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "LockScreenViewController") as? LockScreenViewController else {
            fatalError("Could not find LockScreenViewController in Storyboard. Check the Storyboard ID.")
        }
        
        // Create a borderless window that covers the entire screen
        let lockWindow = NSWindow(contentViewController: vc)
        lockWindow.styleMask = [.borderless]
        lockWindow.isOpaque = false
        lockWindow.backgroundColor = .clear
        lockWindow.level = .screenSaver // Ensures it's on top of other windows
        lockWindow.setFrame(NSScreen.main!.frame, display: true)
        
        let wc = NSWindowController(window: lockWindow)
        lockScreenWindowController = wc
        
        // Set the delegate to be notified upon successful unlock
        vc.delegate = self
        
        wc.showWindow(self)
    }
    
    @objc func settingsDidChange() {
        print("Settings changed, updating activity monitor")
        activityMonitor.updateFromSettings()
    }
}

// Implement the delegate protocol to handle the unlock event
extension AppDelegate: LockScreenDelegate {
    func didUnlockScreen() {
        print("Screen unlocked by user.")
        lockScreenWindowController?.close()
        lockScreenWindowController = nil
        // Reset the inactivity timer to start monitoring again
        activityMonitor.resetTimer()
    }
}

// Custom Notification Name for better code readability
extension Notification.Name {
    static let userDidBecomeInactive = Notification.Name("userDidBecomeInactive")
    static let settingsDidChange = Notification.Name("settingsDidChange")
}
