import Cocoa

class SettingsViewController: NSViewController {

    // MARK: - Outlets
    
    // General Tab
    @IBOutlet weak var launchAtLoginSwitch: NSSwitch?
    @IBOutlet weak var hideFromDockSwitch: NSSwitch?
    @IBOutlet weak var startMinimizedSwitch: NSSwitch?

    // Matrix Tab
    @IBOutlet weak var characterColorWell: NSColorWell?
    @IBOutlet weak var animationSpeedSlider: NSSlider?
    @IBOutlet weak var animationSpeedLabel: NSTextField?
    @IBOutlet weak var densitySlider: NSSlider?
    @IBOutlet weak var densityLabel: NSTextField?
    @IBOutlet weak var soundEffectsSwitch: NSSwitch?
    
    // Security Tab
    @IBOutlet weak var automaticLockSwitch: NSSwitch?
    @IBOutlet weak var timeoutSlider: NSSlider?
    @IBOutlet weak var timeoutLabel: NSTextField?
    @IBOutlet weak var passwordProtectionSwitch: NSSwitch?
    @IBOutlet weak var passwordField: NSSecureTextField?
    @IBOutlet weak var setPasswordButton: NSButton?
    @IBOutlet weak var maxAttemptsStepper: NSStepper?
    @IBOutlet weak var maxAttemptsLabel: NSTextField?
    @IBOutlet weak var lockoutDurationSlider: NSSlider?
    @IBOutlet weak var lockoutDurationLabel: NSTextField?
    
    // Control Buttons
    @IBOutlet weak var lockScreenNowButton: NSButton?
    @IBOutlet weak var testMatrixButton: NSButton?
    @IBOutlet weak var startStopButton: NSButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure view is loaded before accessing outlets
        view.layoutSubtreeIfNeeded()
        
        loadSettings()
        updateUIState()
    }
    
    private func loadSettings() {
        let settings = UserSettings.shared
        
        // General
        launchAtLoginSwitch?.state = LaunchAtLogin.isEnabled ? .on : .off
        hideFromDockSwitch?.state = settings.hideFromDock ? .on : .off
        startMinimizedSwitch?.state = settings.startMinimized ? .on : .off
        
        // Matrix
        characterColorWell?.color = settings.matrixCharacterColor
        animationSpeedSlider?.doubleValue = settings.matrixAnimationSpeed
        densitySlider?.doubleValue = settings.matrixDensity
        soundEffectsSwitch?.state = settings.matrixSoundEffects ? .on : .off
        
        // Security
        automaticLockSwitch?.state = settings.enableAutomaticLock ? .on : .off
        timeoutSlider?.doubleValue = settings.inactivityTimeout
        passwordProtectionSwitch?.state = settings.enablePasswordProtection ? .on : .off
        maxAttemptsStepper?.integerValue = settings.maxFailedAttempts
        lockoutDurationSlider?.doubleValue = settings.lockoutDuration
        
        // Update control buttons
        updateControlButtons()
    }
    
    private func updateUIState() {

        // Matrix Labels
        animationSpeedLabel?.stringValue = String(format: "%.1fx", animationSpeedSlider?.doubleValue ?? 1.0)
        densityLabel?.stringValue = "\(Int((densitySlider?.doubleValue ?? 0.7) * 100))%"
        
        // Security Labels & Controls
        timeoutLabel?.stringValue = "Lock after \(Int(timeoutSlider?.doubleValue ?? 60)) seconds"
        maxAttemptsLabel?.stringValue = "\(maxAttemptsStepper?.integerValue ?? 5) attempts"
        updateLockoutLabel(duration: lockoutDurationSlider?.doubleValue ?? 300)
        
        let autoLockEnabled = automaticLockSwitch?.state == .on
        timeoutSlider?.isEnabled = autoLockEnabled
        
        let passwordProtectionEnabled = passwordProtectionSwitch?.state == .on
        passwordField?.isEnabled = passwordProtectionEnabled
        setPasswordButton?.isEnabled = passwordProtectionEnabled
        maxAttemptsStepper?.isEnabled = passwordProtectionEnabled
        lockoutDurationSlider?.isEnabled = passwordProtectionEnabled
        
        updateControlButtons()
    }
    
    private func updateControlButtons() {
        let isMonitoring = UserSettings.shared.enableAutomaticLock
        startStopButton?.title = isMonitoring ? "⏸️ Stop Monitoring" : "▶️ Start Monitoring"
    }
    
    // MARK: - Actions

    @IBAction func settingDidChange(_ sender: Any) {
        // This generic action will trigger for most controls.
        // We update the model based on which control sent the action.
        
        if let control = sender as? NSControl {
            let settings = UserSettings.shared
            
            switch control {
            // General
            case launchAtLoginSwitch:
                LaunchAtLogin.isEnabled = (launchAtLoginSwitch?.state == .on)
            case hideFromDockSwitch:
                settings.hideFromDock = (hideFromDockSwitch?.state == .on)
                showRestartAlert()
            case startMinimizedSwitch:
                settings.startMinimized = (startMinimizedSwitch?.state == .on)
            
            // Matrix
            case characterColorWell:
                if let colorWell = characterColorWell {
                    settings.matrixCharacterColor = colorWell.color
                }
            case animationSpeedSlider:
                if let slider = animationSpeedSlider {
                    settings.matrixAnimationSpeed = slider.doubleValue
                }
            case densitySlider:
                if let slider = densitySlider {
                    settings.matrixDensity = slider.doubleValue
                }
            case soundEffectsSwitch:
                settings.matrixSoundEffects = (soundEffectsSwitch?.state == .on)
                
            // Security
            case automaticLockSwitch:
                settings.enableAutomaticLock = (automaticLockSwitch?.state == .on)
                // Trigger monitoring start/stop
                let notificationName = settings.enableAutomaticLock ? Notifications.startMonitoring : Notifications.stopMonitoring
                NotificationCenter.default.post(name: notificationName, object: nil)
            case timeoutSlider:
                if let slider = timeoutSlider {
                    settings.inactivityTimeout = slider.doubleValue
                }
            case passwordProtectionSwitch:
                settings.enablePasswordProtection = (passwordProtectionSwitch?.state == .on)
            case maxAttemptsStepper:
                if let stepper = maxAttemptsStepper {
                    settings.maxFailedAttempts = stepper.integerValue
                }
            case lockoutDurationSlider:
                if let slider = lockoutDurationSlider {
                    settings.lockoutDuration = slider.doubleValue
                }
            default:
                break
            }
        }
        
        updateUIState()
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }

    @IBAction func setPasswordClicked(_ sender: NSButton) {
        guard let passwordField = passwordField else { return }
        let password = passwordField.stringValue
        if !password.isEmpty {
            UserSettings.shared.setPassword(password)
            passwordField.stringValue = "" // Clear field after setting
            showPasswordConfirmation()
        }
    }
    
    @IBAction func lockScreenNowClicked(_ sender: NSButton) {
        // Trigger lock screen immediately
        NotificationCenter.default.post(name: Notifications.userDidBecomeInactive, object: nil)
    }
    
    @IBAction func testMatrixClicked(_ sender: NSButton) {
        // Test matrix screensaver
        testMatrixScreensaver()
    }
    
    @IBAction func startStopClicked(_ sender: NSButton) {
        // Toggle monitoring
        let wasEnabled = UserSettings.shared.enableAutomaticLock
        UserSettings.shared.enableAutomaticLock.toggle()
        
        let notificationName = UserSettings.shared.enableAutomaticLock ? Notifications.startMonitoring : Notifications.stopMonitoring
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        // Update UI to reflect changes
        automaticLockSwitch?.state = UserSettings.shared.enableAutomaticLock ? .on : .off
        updateUIState()
        
        // Notify other parts of the app
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        
        print("🔄 Monitoring toggled from settings: \(UserSettings.shared.enableAutomaticLock)")
    }
    
    // MARK: - Helper Methods
    
    private func updateLockoutLabel(duration: TimeInterval) {
        let minutes = Int(duration / 60)
        lockoutDurationLabel?.stringValue = "\(minutes) min lockout"
    }
    
    private func showRestartAlert() {
        let alert = NSAlert()
        alert.messageText = "Restart Required"
        alert.informativeText = "Hiding the app from the Dock requires a restart of MatrixLocker to take effect."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showPasswordConfirmation() {
        let alert = NSAlert()
        alert.messageText = "Password Set"
        alert.informativeText = "Your new password has been securely saved."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func testMatrixScreensaver() {
        // Create test matrix screensaver window
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "LockScreenViewController") as? LockScreenViewController else {
            print("❌ Could not find LockScreenViewController")
            return
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
        
        // Add escape key handler for easy exit
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak testWindowController] event in
            if event.keyCode == 53 { // Escape key
                testWindowController?.close()
                return nil
            }
            return event
        }
        
        // Remove monitor when window closes
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: testWindow, queue: .main) { _ in
            if let monitor = monitor {
                NSEvent.removeMonitor(monitor)
            }
        }
    }
}

// Helper class for test delegate
private class TestScreenDelegate: LockScreenDelegate {
    private let onUnlock: () -> Void
    
    init(onUnlock: @escaping () -> Void) {
        self.onUnlock = onUnlock
    }
    
    func didUnlockScreen() {
        onUnlock()
    }
}
