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

        // Apply dock visibility setting - start with regular mode
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
        
        // Close all windows
        if let settingsController = settingsWindowController {
            settingsController.close()
        }
        if let lockController = lockScreenWindowController {
            lockController.close()
        }
        
        // Remove status item
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
        
        NotificationCenter.default.removeObserver(self)
        print("🔚 MatrixLocker: Application terminating")
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
        print("🔧 Setting up system tray...")
        
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let statusItem = statusItem else {
            print("❌ Failed to create status item")
            return
        }
        
        guard let button = statusItem.button else {
            print("❌ Failed to get status item button")
            return
        }
        
        // Set up button
        button.image = NSImage(systemSymbolName: "grid", accessibilityDescription: "MatrixLocker")
        button.image?.isTemplate = true // Makes it adapt to dark/light mode
        button.imageScaling = .scaleProportionallyDown
        
        // Alternative fallback image if grid doesn't work
        if button.image == nil {
            button.title = "M"
            button.font = NSFont.boldSystemFont(ofSize: 14)
        }
        
        print("✅ Status item button configured with image: \(button.image != nil)")
        
        updateStatusMenu()
        print("✅ System tray setup complete")
        
        // Force menu bar to refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.statusItem?.button?.needsDisplay = true
        }
    }
    
    private func updateStatusMenu() {
        // Clear existing menu to prevent duplicates
        let menu = NSMenu()
        menu.removeAllItems() // Ensure clean slate
        
        let settings = UserSettings.shared
        
        // Status Item
        let statusTitle = settings.enableAutomaticLock ? "Monitoring Active (\(Int(settings.inactivityTimeout))s)" : "Monitoring Disabled"
        let statusMenuItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        menu.addItem(NSMenuItem.separator())

        // Quick Actions
        menu.addItem(NSMenuItem(title: "🔒 Lock Screen Now", action: #selector(lockScreenNow), keyEquivalent: "l"))
        
        // Start/Stop Monitoring
        let toggleTitle = settings.enableAutomaticLock ? "⏸️ Stop Monitoring" : "▶️ Start Monitoring"
        menu.addItem(NSMenuItem(title: toggleTitle, action: #selector(toggleMonitoring), keyEquivalent: ""))

        // Test Matrix Screensaver
        menu.addItem(NSMenuItem(title: "🧪 Test Matrix Screensaver", action: #selector(testMatrixScreensaver), keyEquivalent: "t"))

        menu.addItem(NSMenuItem(title: "⏰ Activate in 10s", action: #selector(activateNow), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        
        // Dock visibility toggle
        let dockTitle = UserSettings.shared.hideFromDock ? "📱 Show in Dock" : "🫥 Hide from Dock"
        menu.addItem(NSMenuItem(title: dockTitle, action: #selector(toggleDockVisibility), keyEquivalent: ""))
        
        // Settings
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        
        menu.addItem(NSMenuItem.separator())

        // Quit
        menu.addItem(NSMenuItem(title: "Quit MatrixLocker", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        // Replace the entire menu to prevent duplicates
        self.statusItem?.menu = menu
        updateStatusItemIcon()
        
        print("🔄 Menu updated with \(menu.items.count) items")
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
            print("🫥 App hidden from dock (accessory mode)")
        } else {
            NSApp.setActivationPolicy(.regular)
            print("👁️ App visible in dock (regular mode)")
        }
    }
    
    // MARK: - Menu Actions
    
    @objc private func lockScreenNow() {
        showLockScreen()
    }
    
    @objc private func toggleMonitoring() {
        let wasEnabled = UserSettings.shared.enableAutomaticLock
        UserSettings.shared.enableAutomaticLock.toggle()
        
        let notificationName = UserSettings.shared.enableAutomaticLock ? Notifications.startMonitoring : Notifications.stopMonitoring
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        // Only update menu if state actually changed
        if wasEnabled != UserSettings.shared.enableAutomaticLock {
            updateStatusMenu()
            print("🔄 Monitoring toggled: \(UserSettings.shared.enableAutomaticLock)")
        }
    }
    
    @objc private func activateNow() {
        NotificationCenter.default.post(name: Notifications.activateNow, object: nil)
    }
    
    @objc private func toggleDockVisibility() {
        UserSettings.shared.hideFromDock.toggle()
        updateDockVisibility()
        updateStatusMenu()
        print("🔄 Dock visibility toggled: hidden = \(UserSettings.shared.hideFromDock)")
    }
    
    @objc private func testMatrixScreensaver() {
        // Show matrix screensaver for testing without password protection
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "LockScreenViewController") as? LockScreenViewController else {
            fatalError("Could not find LockScreenViewController in Storyboard.")
        }
        
        // Create a test window that can be closed with Escape
        let testWindow = NSWindow(contentViewController: vc)
        testWindow.styleMask = [.borderless]
        testWindow.isOpaque = true
        testWindow.backgroundColor = .black
        testWindow.level = .normal // Not screen saver level for testing
        testWindow.setFrame(NSScreen.main!.frame, display: true, animate: false)
        testWindow.title = "Matrix Screensaver Test (Press ESC to close)"
        
        let testWindowController = NSWindowController(window: testWindow)
        
        // Override delegate to close on test
        let testDelegate = TestScreenDelegate { [weak testWindowController] in
            testWindowController?.close()
        }
        vc.delegate = testDelegate
        
        testWindowController.showWindow(self)
        
        // Add escape key handler
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // Escape key
                testWindowController.close()
                return nil
            }
            return event
        }
    }
    
    @objc private func showSettings() {
        // Close and nullify existing settings window if it exists
        if let existingController = settingsWindowController {
            existingController.close()
            settingsWindowController = nil
            print("🗑️ Closed existing settings window")
        }
        
        // Temporarily switch to regular app to show window properly
        NSApp.setActivationPolicy(.regular)
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "SettingsViewController") as? SettingsViewController else {
            print("❌ Could not find SettingsViewController")
            return
        }
        
        let window = NSWindow(contentViewController: vc)
        window.title = "MatrixLocker Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 600, height: 400))
        window.center()
        
        // Make window properly visible
        window.isReleasedWhenClosed = true
        window.level = .normal
        window.collectionBehavior = [.managed, .participatesInCycle]
        
        // Create new controller
        settingsWindowController = NSWindowController(window: window)
        
        // Set delegate to handle window closing
        window.delegate = self
        
        // Show window and activate app
        settingsWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        
        print("✅ Settings window opened with title: '\(window.title)'")
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

// MARK: - Test Screen Delegate
class TestScreenDelegate: LockScreenDelegate {
    private let onUnlock: () -> Void
    
    init(onUnlock: @escaping () -> Void) {
        self.onUnlock = onUnlock
    }
    
    func didUnlockScreen() {
        onUnlock()
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

// MARK: - NSWindowDelegate
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow,
           window === settingsWindowController?.window {
            settingsWindowController = nil
            
            // Return to accessory mode when settings window closes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if UserSettings.shared.hideFromDock {
                    NSApp.setActivationPolicy(.accessory)
                } else {
                    NSApp.setActivationPolicy(.regular)
                }
            }
            
            print("🗑️ Settings window controller nullified, returned to accessory mode")
        }
    }
    
    func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow,
           window === settingsWindowController?.window {
            // Ensure app is fully active when settings window becomes key
            NSApp.activate(ignoringOtherApps: true)
            print("✅ Settings window became key")
        }
    }
}
