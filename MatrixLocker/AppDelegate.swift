import Cocoa
import Foundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var lockScreenWindowController: NSWindowController?
    private var activityMonitor: ActivityMonitor?
    var statusItem: NSStatusItem?
    var settingsWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupSystemTray()
        activityMonitor = ActivityMonitor()
        
        if !UserSettings.shared.startMinimized {
            showSettings()
        }
        
        // Update application's presence in Dock based on settings
        if UserSettings.shared.hideFromDock {
            NSApp.setActivationPolicy(.accessory)
        }
        
        NotificationCenter.default.addObserver(self,
                                            selector: #selector(settingsDidChange),
                                            name: Notifications.settingsDidChange,
                                            object: nil)
        
        NotificationCenter.default.addObserver(self,
                                            selector: #selector(showLockScreen),
                                            name: Notifications.userDidBecomeInactive,
                                            object: nil)
        
        if UserSettings.shared.enableAutomaticLock {
            NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        activityMonitor?.stopMonitoring()
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showSettings()
        }
        return true
    }

    @objc func showLockScreen() {
        guard lockScreenWindowController == nil else { return }
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let wc = storyboard.instantiateController(withIdentifier: "LockScreen") as? NSWindowController,
              let vc = wc.contentViewController as? LockScreenViewController else {
            return
        }
        
        lockScreenWindowController = wc
        vc.delegate = self
        
        wc.window?.level = .screenSaver
        wc.window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        SoundManager.shared.play(effect: .lock)
        wc.showWindow(self)
        
        if let screen = NSScreen.main {
            wc.window?.setFrame(screen.frame, display: true)
        }
    }
    
    @objc func settingsDidChange() {
        // Refresh the status item to reflect new settings
        updateStatusMenu()
        
        // Update dock visibility
        if UserSettings.shared.hideFromDock {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }
    
    // MARK: - System Tray Setup
    
    private func setupSystemTray() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        // Accessibility label for the status bar icon
        statusItem?.button?.setAccessibilityLabel(NSLocalizedString("Status Bar Icon", comment: ""))
        // Tooltip for the status bar icon
        statusItem?.button?.toolTip = NSLocalizedString("MatrixLocker status icon. Shows lock state.", comment: "")
        updateStatusMenu()
    }
    
    private func updateStatusMenu() {
        let menu = NSMenu()
        
        let monitoringEnabled = UserSettings.shared.enableAutomaticLock
        menu.addItem(withTitle: monitoringEnabled ? "Disable Auto-Lock" : "Enable Auto-Lock",
                    action: #selector(toggleMonitoring),
                    keyEquivalent: "")
        
        menu.addItem(withTitle: "Lock Now",
                    action: #selector(lockScreenNow),
                    keyEquivalent: "l")
        
        menu.addItem(withTitle: "Lock in 10 seconds",
                    action: #selector(activateNow),
                    keyEquivalent: "")
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Settings",
                    action: #selector(showSettings),
                    keyEquivalent: ",")
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Quit",
                    action: #selector(NSApplication.terminate(_:)),
                    keyEquivalent: "q")
        
        statusItem?.menu = menu
        updateStatusItemIcon()
    }
    
    private func updateStatusItemIcon() {
        if let button = statusItem?.button {
            button.image = NSImage(named: UserSettings.shared.enableAutomaticLock ? "StatusIconActive" : "StatusIconInactive")
        }
    }
    
    // MARK: - Menu Actions
    
    @objc private func lockScreenNow() {
        showLockScreen()
    }
    
    @objc private func toggleMonitoring() {
        UserSettings.shared.enableAutomaticLock.toggle()
        if UserSettings.shared.enableAutomaticLock {
            NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
        } else {
            NotificationCenter.default.post(name: Notifications.stopMonitoring, object: nil)
        }
        updateStatusMenu()
    }
    
    @objc private func activateNow() {
        NotificationCenter.default.post(name: Notifications.activateNow, object: nil)
    }

    @objc private func showSettings() {
        if settingsWindowController == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            settingsWindowController = storyboard.instantiateController(withIdentifier: "Settings") as? NSWindowController
        }
        
        settingsWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - LockScreenDelegate
extension AppDelegate: LockScreenDelegate {
    func didUnlockScreen() {
        lockScreenWindowController?.close()
        lockScreenWindowController = nil
        
        if UserSettings.shared.enableAutomaticLock {
            NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
        }
    }
}
