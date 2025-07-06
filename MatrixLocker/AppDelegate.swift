import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var lockScreenWindowController: NSWindowController?
    private var activityMonitor: ActivityMonitor?
    var statusItem: NSStatusItem?
    var settingsWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupSystemTray()
        
        activityMonitor = ActivityMonitor()

        if UserSettings.shared.enableAutomaticLock {
            NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLockScreen), name: Notifications.userDidBecomeInactive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: Notifications.settingsDidChange, object: nil)
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

        SoundManager.shared.play(effect: .lock)
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "LockScreenViewController") as? LockScreenViewController else {
            fatalError("Could not find LockScreenViewController in Storyboard.")
        }
        
        let lockWindow = NSWindow(contentViewController: vc)
        lockWindow.styleMask = [.borderless]
        lockWindow.isOpaque = true
        lockWindow.backgroundColor = .black
        lockWindow.level = .screenSaver
        lockWindow.setFrame(NSScreen.main!.frame, display: true, animate: false)
        
        let wc = NSWindowController(window: lockWindow)
        lockScreenWindowController = wc
        vc.delegate = self
        
        wc.showWindow(self)
    }
    
    @objc func settingsDidChange() {
        // Refresh the status item to reflect new settings
        updateStatusMenu()
    }
    
    // MARK: - System Tray Setup
    
    private func setupSystemTray() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "grid", accessibilityDescription: "MatrixLocker")
        updateStatusMenu()
    }
    
    private func updateStatusMenu() {
        let menu = NSMenu()
        let settings = UserSettings.shared
        
        // Status Item
        let statusTitle = settings.enableAutomaticLock ? "Monitoring Active (\(Int(settings.inactivityTimeout))s)" : "Monitoring Disabled"
        let statusItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        statusItem.isEnabled = false
        menu.addItem(statusItem)
        
        menu.addItem(NSMenuItem.separator())

        // Quick Actions
        menu.addItem(NSMenuItem(title: "Lock Screen Now", action: #selector(lockScreenNow), keyEquivalent: "l"))
        
        let toggleTitle = settings.enableAutomaticLock ? "Disable Monitoring" : "Enable Monitoring"
        menu.addItem(NSMenuItem(title: toggleTitle, action: #selector(toggleMonitoring), keyEquivalent: ""))

        menu.addItem(NSMenuItem(title: "Activate in 10s", action: #selector(activateNow), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        
        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(title: "Quit MatrixLocker", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
        updateStatusItemIcon()
    }
    
    private func updateStatusItemIcon() {
        if let button = statusItem?.button {
            let isEnabled = UserSettings.shared.enableAutomaticLock
            button.contentTintColor = isEnabled ? UserSettings.shared.matrixCharacterColor : .tertiaryLabelColor
        }
    }
    
    // MARK: - Menu Actions
    
    @objc private func lockScreenNow() {
        showLockScreen()
    }
    
    @objc private func toggleMonitoring() {
        UserSettings.shared.enableAutomaticLock.toggle()
        let notificationName = UserSettings.shared.enableAutomaticLock ? Notifications.startMonitoring : Notifications.stopMonitoring
        NotificationCenter.default.post(name: notificationName, object: nil)
        updateStatusMenu()
    }
    
    @objc private func activateNow() {
        NotificationCenter.default.post(name: Notifications.activateNow, object: nil)
    }

    @objc private func showSettings() {
        if settingsWindowController == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateController(withIdentifier: "SettingsViewController") as? SettingsViewController else {
                return
            }
            let window = NSWindow(contentViewController: vc)
            window.title = "MatrixLocker Settings"
            window.styleMask = [.titled, .closable, .miniaturizable]
            settingsWindowController = NSWindowController(window: window)
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
        // Restart monitoring if it was enabled
        if UserSettings.shared.enableAutomaticLock {
            activityMonitor?.startMonitoring()
        }
    }
}
