import Cocoa

class GeneralSettingsViewController: NSViewController {

    // Activity & Lock Settings
    @IBOutlet weak var timeoutLabel: NSTextField!
    @IBOutlet weak var timeoutSlider: NSSlider!
    @IBOutlet weak var automaticLockSwitch: NSSwitch!
    @IBOutlet weak var passwordProtectionSwitch: NSSwitch!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var failedAttemptsStepper: NSStepper!
    @IBOutlet weak var failedAttemptsLabel: NSTextField!
    @IBOutlet weak var lockoutSlider: NSSlider!
    @IBOutlet weak var lockoutLabel: NSTextField!
    
    // Matrix Effect Settings
    @IBOutlet weak var characterColorWell: NSColorWell!
    @IBOutlet weak var animationSpeedSlider: NSSlider!
    @IBOutlet weak var animationSpeedLabel: NSTextField!
    @IBOutlet weak var densitySlider: NSSlider!
    @IBOutlet weak var densityLabel: NSTextField!
    @IBOutlet weak var soundEffectsSwitch: NSSwitch!
    @IBOutlet weak var showTimeRemainingSwitch: NSSwitch!
    
    // App Behavior Settings
    @IBOutlet weak var launchAtLoginSwitch: NSSwitch!
    @IBOutlet weak var hideFromDockSwitch: NSSwitch!
    @IBOutlet weak var startMinimizedSwitch: NSSwitch!

    private var startButton: NSButton!
    private var stopButton: NSButton!
    private var activateNowButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        setupUI()
    }
    
    private func setupUI() {
        // Set up modern styling for the settings view
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor

        // Create control buttons
        startButton = NSButton(title: "Start Monitoring", target: self, action: #selector(startMonitoringClicked))
        stopButton = NSButton(title: "Stop Monitoring", target: self, action: #selector(stopMonitoringClicked))
        activateNowButton = NSButton(title: "Activate Now (10s)", target: self, action: #selector(activateNowClicked))

        let stackView = NSStackView(views: [startButton, stopButton, activateNowButton])
        stackView.orientation = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    @objc private func startMonitoringClicked() {
        NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
    }

    @objc private func stopMonitoringClicked() {
        NotificationCenter.default.post(name: Notifications.stopMonitoring, object: nil)
    }

    @objc private func activateNowClicked() {
        NotificationCenter.default.post(name: Notifications.activateNow, object: nil)
    }

    private func loadSettings() {
        let settings = UserSettings.shared
        
        // Activity Time Limit
        let timeout = settings.inactivityTimeout
        timeoutSlider?.doubleValue = timeout
        timeoutLabel?.stringValue = "Lock after \(Int(timeout)) seconds of activity"
        
        // Security Settings
        automaticLockSwitch?.state = settings.enableAutomaticLock ? .on : .off
        passwordProtectionSwitch?.state = settings.enablePasswordProtection ? .on : .off
        passwordField?.stringValue = settings.lockPassword ?? ""
        
        // Failed Attempts
        failedAttemptsStepper?.doubleValue = Double(settings.maxFailedAttempts)
        failedAttemptsLabel?.stringValue = "\(settings.maxFailedAttempts)"
        
        // Lockout Duration
        lockoutSlider?.doubleValue = settings.lockoutDuration
        updateLockoutLabel(duration: settings.lockoutDuration)
        
        // Matrix Effect Settings
        characterColorWell?.color = settings.matrixCharacterColor
        
        animationSpeedSlider?.doubleValue = settings.matrixAnimationSpeed
        animationSpeedLabel?.stringValue = String(format: "%.1fx", settings.matrixAnimationSpeed)
        
        densitySlider?.doubleValue = settings.matrixDensity
        densityLabel?.stringValue = "\(Int(settings.matrixDensity * 100))%"
        
        soundEffectsSwitch?.state = settings.matrixSoundEffects ? .on : .off
        showTimeRemainingSwitch?.state = settings.showTimeRemaining ? .on : .off
        
        // App Behavior Settings
        launchAtLoginSwitch?.state = LaunchAtLogin.isEnabled ? .on : .off
        hideFromDockSwitch?.state = settings.hideFromDock ? .on : .off
        startMinimizedSwitch?.state = settings.startMinimized ? .on : .off
        
        // Update UI state
        updateAutomaticLockUI()
    }

    @IBAction func sliderDidChange(_ sender: NSSlider) {
        let newTimeout = sender.doubleValue
        timeoutLabel?.stringValue = "Lock after \(Int(newTimeout)) seconds of activity"
        UserSettings.shared.inactivityTimeout = newTimeout
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func colorDidChange(_ sender: NSColorWell) {
        UserSettings.shared.matrixCharacterColor = sender.color
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func launchAtLoginDidChange(_ sender: NSSwitch) {
        LaunchAtLogin.isEnabled = (sender.state == .on)
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    // MARK: - Matrix Effect Actions
    
    @IBAction func animationSpeedDidChange(_ sender: NSSlider) {
        let speed = sender.doubleValue
        UserSettings.shared.matrixAnimationSpeed = speed
        animationSpeedLabel?.stringValue = String(format: "%.1fx", speed)
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func densityDidChange(_ sender: NSSlider) {
        let density = sender.doubleValue
        UserSettings.shared.matrixDensity = density
        densityLabel?.stringValue = "\(Int(density * 100))%"
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func soundEffectsDidChange(_ sender: NSSwitch) {
        UserSettings.shared.matrixSoundEffects = (sender.state == .on)
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func showTimeRemainingDidChange(_ sender: NSSwitch) {
        UserSettings.shared.showTimeRemaining = (sender.state == .on)
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    // MARK: - App Behavior Actions
    
    @IBAction func hideFromDockDidChange(_ sender: NSSwitch) {
        UserSettings.shared.hideFromDock = (sender.state == .on)
        
        // This will require app restart to take effect
        let alert = NSAlert()
        alert.messageText = "Restart Required"
        alert.informativeText = "You'll need to restart MatrixLocker for this change to take effect."
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func startMinimizedDidChange(_ sender: NSSwitch) {
        UserSettings.shared.startMinimized = (sender.state == .on)
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    // MARK: - Security Settings Actions
    
    @IBAction func automaticLockDidChange(_ sender: NSSwitch) {
        UserSettings.shared.enableAutomaticLock = (sender.state == .on)
        updateAutomaticLockUI()
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func passwordProtectionDidChange(_ sender: NSSwitch) {
        UserSettings.shared.enablePasswordProtection = (sender.state == .on)
        updatePasswordProtectionUI()
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func passwordDidChange(_ sender: NSSecureTextField) {
        UserSettings.shared.setPassword(sender.stringValue)
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func failedAttemptsDidChange(_ sender: NSStepper) {
        guard let failedAttemptsLabel = failedAttemptsLabel else {
            print("❌ Error: failedAttemptsLabel outlet not connected")
            return
        }
        
        let attempts = Int(sender.doubleValue)
        UserSettings.shared.maxFailedAttempts = attempts
        failedAttemptsLabel.stringValue = "\(attempts)"
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    @IBAction func lockoutDurationDidChange(_ sender: NSSlider) {
        let duration = sender.doubleValue
        UserSettings.shared.lockoutDuration = duration
        updateLockoutLabel(duration: duration)
        
        // Notify about settings change
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }
    
    // MARK: - Helper Methods
    
    private func updateAutomaticLockUI() {
        let isEnabled = automaticLockSwitch?.state == .on
        timeoutSlider?.isEnabled = isEnabled
        passwordProtectionSwitch?.isEnabled = isEnabled


        // Also update password protection UI
        updatePasswordProtectionUI()
    }
    
    private func updatePasswordProtectionUI() {
        let automaticLockEnabled = automaticLockSwitch?.state == .on
        let passwordProtectionEnabled = passwordProtectionSwitch?.state == .on
        let isEnabled = (automaticLockEnabled) && (passwordProtectionEnabled)
        
        passwordField?.isEnabled = isEnabled
        failedAttemptsStepper?.isEnabled = isEnabled
        lockoutSlider?.isEnabled = isEnabled
    }
    
    private func updateLockoutLabel(duration: TimeInterval) {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            lockoutLabel?.stringValue = "\(minutes) minutes"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                lockoutLabel?.stringValue = "\(hours) hour\(hours > 1 ? "s" : "")"
            } else {
                lockoutLabel?.stringValue = "\(hours)h \(remainingMinutes)m"
            }
        }
    }
}
