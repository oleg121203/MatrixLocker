import Cocoa

class GeneralSettingsViewController: NSViewController {

    @IBOutlet weak var timeoutLabel: NSTextField!
    @IBOutlet weak var timeoutSlider: NSSlider!
    @IBOutlet weak var characterColorWell: NSColorWell!
    @IBOutlet weak var launchAtLoginSwitch: NSSwitch!
    
    // Security Settings Outlets
    @IBOutlet weak var automaticLockSwitch: NSSwitch!
    @IBOutlet weak var passwordProtectionSwitch: NSSwitch!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var failedAttemptsStepper: NSStepper!
    @IBOutlet weak var failedAttemptsLabel: NSTextField!
    @IBOutlet weak var lockoutSlider: NSSlider!
    @IBOutlet weak var lockoutLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
    }

    private func loadSettings() {
        let settings = UserSettings.shared
        
        // Inactivity Timeout
        let timeout = settings.inactivityTimeout
        timeoutSlider.doubleValue = timeout
        timeoutLabel.stringValue = "\(Int(timeout)) seconds"
        
        // Matrix Color
        characterColorWell.color = settings.matrixCharacterColor
        
        // Launch at Login
        launchAtLoginSwitch.state = LaunchAtLogin.isEnabled ? .on : .off
        
        // Security Settings
        automaticLockSwitch.state = settings.enableAutomaticLock ? .on : .off
        passwordProtectionSwitch.state = settings.enablePasswordProtection ? .on : .off
        passwordField.stringValue = settings.lockPassword ?? ""
        
        // Failed Attempts
        failedAttemptsStepper.doubleValue = Double(settings.maxFailedAttempts)
        failedAttemptsLabel.stringValue = "\(settings.maxFailedAttempts)"
        
        // Lockout Duration
        lockoutSlider.doubleValue = settings.lockoutDuration
        updateLockoutLabel(duration: settings.lockoutDuration)
        
        // Update UI state based on automatic lock and password protection settings
        updateAutomaticLockUI()
    }

    @IBAction func sliderDidChange(_ sender: NSSlider) {
        let newTimeout = sender.doubleValue
        timeoutLabel.stringValue = "\(Int(newTimeout)) seconds"
        UserSettings.shared.inactivityTimeout = newTimeout
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func colorDidChange(_ sender: NSColorWell) {
        UserSettings.shared.matrixCharacterColor = sender.color
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func launchAtLoginDidChange(_ sender: NSSwitch) {
        LaunchAtLogin.isEnabled = (sender.state == .on)
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    // MARK: - Security Settings Actions
    
    @IBAction func automaticLockDidChange(_ sender: NSSwitch) {
        UserSettings.shared.enableAutomaticLock = (sender.state == .on)
        updateAutomaticLockUI()
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func passwordProtectionDidChange(_ sender: NSSwitch) {
        UserSettings.shared.enablePasswordProtection = (sender.state == .on)
        updatePasswordProtectionUI()
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func passwordDidChange(_ sender: NSSecureTextField) {
        UserSettings.shared.setPassword(sender.stringValue)
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func failedAttemptsDidChange(_ sender: NSStepper) {
        let attempts = Int(sender.doubleValue)
        UserSettings.shared.maxFailedAttempts = attempts
        failedAttemptsLabel.stringValue = "\(attempts)"
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func lockoutDurationDidChange(_ sender: NSSlider) {
        let duration = sender.doubleValue
        UserSettings.shared.lockoutDuration = duration
        updateLockoutLabel(duration: duration)
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    // MARK: - Helper Methods
    
    private func updateAutomaticLockUI() {
        let isEnabled = automaticLockSwitch.state == .on
        timeoutSlider.isEnabled = isEnabled
        passwordProtectionSwitch.isEnabled = isEnabled
        
        // Also update password protection UI
        updatePasswordProtectionUI()
    }
    
    private func updatePasswordProtectionUI() {
        let automaticLockEnabled = automaticLockSwitch.state == .on
        let passwordProtectionEnabled = passwordProtectionSwitch.state == .on
        let isEnabled = automaticLockEnabled && passwordProtectionEnabled
        
        passwordField.isEnabled = isEnabled
        failedAttemptsStepper.isEnabled = isEnabled
        lockoutSlider.isEnabled = isEnabled
    }
    
    private func updateAutomaticLockUI() {
        // Implement any additional UI updates for automatic lock here if needed
    }
    
    private func updateLockoutLabel(duration: TimeInterval) {
        let minutes = Int(duration / 60)
        if minutes < 60 {
            lockoutLabel.stringValue = "\(minutes) minutes"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                lockoutLabel.stringValue = "\(hours) hour\(hours > 1 ? "s" : "")"
            } else {
                lockoutLabel.stringValue = "\(hours)h \(remainingMinutes)m"
            }
        }
    }
}
