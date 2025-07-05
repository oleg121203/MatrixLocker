import Cocoa
import Foundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var lockScreenWindowController: NSWindowController?
    private var activityMonitor: ActivityMonitor?
    var statusItem: NSStatusItem?
    var settingsWindowController: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupSignalHandlers()

        // Setup system tray
        setupSystemTray()
        
        // Initialize the new activity monitor
        activityMonitor = ActivityMonitor()

        // Post a notification to start monitoring if enabled in settings
        if UserSettings.shared.enableAutomaticLock {
            NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
        }
        
        // Configure the observer for user inactivity
        NotificationCenter.default.addObserver(self, selector: #selector(showLockScreen), name: Notifications.userDidBecomeInactive, object: nil)
        
        // Configure observer for settings changes
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: Notifications.settingsDidChange, object: nil)
        

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up when the app closes
        activityMonitor?.stopMonitoring()
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
        // The new ActivityMonitor listens for settings changes automatically
        updateStatusItemIcon()
    }
    
    // MARK: - System Tray Setup
    private func setupSystemTray() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            // Create Matrix-style icon
            let image = createMatrixIcon()
            image.size = NSSize(width: 18, height: 18)
            image.isTemplate = true
            button.image = image
            button.toolTip = "MatrixLocker - Screen Lock Manager"
        }
        
        setupStatusMenu()
        updateStatusItemIcon()
    }
    
    private func createMatrixIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Draw matrix-style grid
        let context = NSGraphicsContext.current?.cgContext
        context?.setStrokeColor(NSColor.controlAccentColor.cgColor)
        context?.setLineWidth(1.0)
        
        // Draw vertical lines
        for i in 0...3 {
            let x = CGFloat(i) * 4.5
            context?.move(to: CGPoint(x: x, y: 2))
            context?.addLine(to: CGPoint(x: x, y: 16))
        }
        
        // Draw horizontal lines
        for i in 0...3 {
            let y = CGFloat(i) * 3.5 + 2
            context?.move(to: CGPoint(x: 0, y: y))
            context?.addLine(to: CGPoint(x: 16, y: y))
        }
        
        context?.strokePath()
        
        // Add some "digital" dots
        context?.setFillColor(NSColor.controlAccentColor.cgColor)
        for _ in 0...5 {
            let x = CGFloat.random(in: 2...14)
            let y = CGFloat.random(in: 4...14)
            context?.fillEllipse(in: CGRect(x: x, y: y, width: 1, height: 1))
        }
        
        image.unlockFocus()
        return image
    }
    
    private func setupStatusMenu() {
        let menu = NSMenu()
        
        // Status indicator
        let statusMenuItem = NSMenuItem()
        updateStatusMenuItem(statusMenuItem)
        menu.addItem(statusMenuItem)
        menu.addItem(NSMenuItem.separator())
        
        // Quick actions
        let lockNowItem = NSMenuItem(title: "🔒 Lock Screen Now", action: #selector(lockScreenNow), keyEquivalent: "l")
        lockNowItem.target = self
        menu.addItem(lockNowItem)
        
        let toggleMonitoringItem = NSMenuItem()
        toggleMonitoringItem.target = self
        toggleMonitoringItem.action = #selector(toggleMonitoring)
        updateToggleMenuItem(toggleMonitoringItem)
        menu.addItem(toggleMonitoringItem)
        
        let activateNowItem = NSMenuItem(title: "⚡ Activate Now (10s)", action: #selector(activateNow), keyEquivalent: "")
        activateNowItem.target = self
        menu.addItem(activateNowItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Stealth Mode
        let stealthModeItem = NSMenuItem()
        stealthModeItem.target = self
        stealthModeItem.action = #selector(toggleStealthMode)
        updateStealthModeMenuItem(stealthModeItem)
        menu.addItem(stealthModeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings submenu
        let settingsSubmenu = NSMenu()
        
        let generalSettingsItem = NSMenuItem(title: "General Settings", action: #selector(showSettings), keyEquivalent: "s")
        generalSettingsItem.target = self
        settingsSubmenu.addItem(generalSettingsItem)
        
        let matrixSettingsItem = NSMenuItem(title: "Matrix Animation", action: #selector(showMatrixSettings), keyEquivalent: "")
        matrixSettingsItem.target = self
        settingsSubmenu.addItem(matrixSettingsItem)
        
        let securitySettingsItem = NSMenuItem(title: "Security & Lock", action: #selector(showSecuritySettings), keyEquivalent: "")
        securitySettingsItem.target = self
        settingsSubmenu.addItem(securitySettingsItem)
        
        let settingsMenuItem = NSMenuItem(title: "⚙️ Settings", action: nil, keyEquivalent: "")
        settingsMenuItem.submenu = settingsSubmenu
        menu.addItem(settingsMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // About and Quit
        let aboutItem = NSMenuItem(title: "ℹ️ About MatrixLocker", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        let quitItem = NSMenuItem(title: "❌ Quit MatrixLocker", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    private func updateStatusMenuItem(_ item: NSMenuItem) {
        let isEnabled = UserSettings.shared.enableAutomaticLock
        let timeout = UserSettings.shared.inactivityTimeout
        
        if isEnabled {
            item.title = "Status: Active (Limit: \(Int(timeout))s)"
        } else {
            item.title = "Status: Disabled"
        }
    }
    
    private func updateToggleMenuItem(_ item: NSMenuItem) {
        let isEnabled = UserSettings.shared.enableAutomaticLock
        item.title = isEnabled ? "⏸️ Disable Activity Monitoring" : "▶️ Enable Activity Monitoring"
    }
    
    private func updateStealthModeMenuItem(_ item: NSMenuItem) {
        let isStealthMode = UserSettings.shared.hideFromDock
        item.title = isStealthMode ? "👁️ Exit Stealth Mode" : "🥷 Enter Stealth Mode"
    }
    
    private func updateStatusItemIcon() {
        guard let button = statusItem?.button else { return }
        
        let isEnabled = UserSettings.shared.enableAutomaticLock
        button.image?.isTemplate = true
        
        if isEnabled {
            button.contentTintColor = UserSettings.shared.matrixCharacterColor
        } else {
            button.contentTintColor = NSColor.tertiaryLabelColor
        }
    }
    
    // MARK: - Menu Actions
    @objc private func lockScreenNow() {
        showLockScreen()
    }
    
    @objc private func toggleMonitoring() {
        UserSettings.shared.enableAutomaticLock.toggle()
        
        // Start or stop monitoring based on new setting
        if UserSettings.shared.enableAutomaticLock {
            NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
        } else {
            NotificationCenter.default.post(name: Notifications.stopMonitoring, object: nil)
        }
        
        settingsDidChange()
        setupStatusMenu() // Refresh menu
    }
    
    @objc private func activateNow() {
        NotificationCenter.default.post(name: Notifications.activateNow, object: nil)
    }
    
    @objc private func toggleStealthMode() {
        UserSettings.shared.hideFromDock.toggle()
        setupStatusMenu() // Refresh menu
    }
    
    @objc private func showSettings() {
        // Open settings window
        if settingsWindowController == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            if let settingsVC = storyboard.instantiateController(withIdentifier: "SettingsViewController") as? SettingsViewController {
                let window = NSWindow(contentViewController: settingsVC)
                window.title = "MatrixLocker Settings"
                window.styleMask = [.titled, .closable, .miniaturizable]
                window.level = .floating
                settingsWindowController = NSWindowController(window: window)
            }
        }
        
        settingsWindowController?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func showMatrixSettings() {
        // Open settings window with Matrix tab selected
        showSettings()
        // TODO: Add logic to switch to Matrix settings tab
    }
    
    @objc private func showSecuritySettings() {
        // Open settings window with Security tab selected
        showSettings()
        // TODO: Add logic to switch to Security settings tab
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "MatrixLocker"
        alert.informativeText = "Version 1.0\n\nA Matrix-themed screen lock application for macOS.\nDesigned to help manage screen time and secure your session."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(self)
    }

    private func setupSignalHandlers() {
        signal(SIGTERM) { signal in
            print("Received SIGTERM, terminating application gracefully.")
            DispatchQueue.main.async {
                NSApp.terminate(nil)
            }
        }
    }
}

// Implement the delegate protocol to handle the unlock event
extension AppDelegate: LockScreenDelegate {
    func didUnlockScreen() {
        print("Screen unlocked by user.")
        lockScreenWindowController?.close()
        lockScreenWindowController = nil
        // Reset the inactivity timer to start monitoring again
        activityMonitor?.startMonitoring()
    }
}
