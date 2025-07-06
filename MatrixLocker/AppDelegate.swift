import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var lockScreenWindowController: NSWindowController?
    private var activityMonitor: ActivityMonitor?
    var statusItem: NSStatusItem?
    var settingsWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("🚀 MatrixLocker: Application starting...")
        
        // Check system permissions first
        checkSystemPermissions()
        
        setupSystemTray()
        
        activityMonitor = ActivityMonitor()

        // Apply dock visibility setting
        updateDockVisibility()

        if UserSettings.shared.enableAutomaticLock {
            print("🔄 MatrixLocker: Starting automatic monitoring...")
            NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
        } else {
            print("⏸️ MatrixLocker: Automatic monitoring disabled")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLockScreen), name: Notifications.userDidBecomeInactive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: Notifications.settingsDidChange, object: nil)
        
        print("✅ MatrixLocker: Application setup complete")
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
        updateDockVisibility()
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
        let statusMenuItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
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
        
        self.statusItem?.menu = menu
        updateStatusItemIcon()
    }
    
    private func updateStatusItemIcon() {
        if let button = statusItem?.button {
            let isEnabled = UserSettings.shared.enableAutomaticLock
            button.contentTintColor = isEnabled ? UserSettings.shared.matrixCharacterColor : .tertiaryLabelColor
        }
    }
    
    private func updateDockVisibility() {
        let hideFromDock = UserSettings.shared.hideFromDock
        if hideFromDock {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
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
            window.setContentSize(NSSize(width: 600, height: 400))
            window.center()
            settingsWindowController = NSWindowController(window: window)
        }
        
        settingsWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func checkSystemPermissions() {
        // Check Accessibility permissions with prompt
        let options: [String: Any] = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if accessibilityEnabled {
            print("✅ MatrixLocker: Accessibility permissions granted")
        } else {
            print("❌ MatrixLocker: Accessibility permissions NOT granted")
            // Show alert to guide user
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showAccessibilityPermissionAlert()
            }
        }
    }
    
    private func showAccessibilityPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "MatrixLocker needs Accessibility permission to monitor user activity for automatic screen locking.\n\n1. Click 'Open System Preferences'\n2. Click the lock to make changes\n3. Find and check 'MatrixLocker' in the list\n4. Restart MatrixLocker"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
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
