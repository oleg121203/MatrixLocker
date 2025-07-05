import Cocoa

class GeneralSettingsViewController: NSViewController {

    @IBOutlet weak var timeoutLabel: NSTextField!
    @IBOutlet weak var timeoutSlider: NSSlider!
    @IBOutlet weak var characterColorWell: NSColorWell!
    @IBOutlet weak var launchAtLoginSwitch: NSSwitch!
    
    // Security Settings Outlets
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
        passwordProtectionSwitch.state = settings.enablePasswordProtection ? .on : .off
        passwordField.stringValue = settings.lockPassword ?? ""
        
        // Failed Attempts
        failedAttemptsStepper.doubleValue = Double(settings.maxFailedAttempts)
        failedAttemptsLabel.stringValue = "\(settings.maxFailedAttempts)"
        
        // Lockout Duration
        lockoutSlider.doubleValue = settings.lockoutDuration
        updateLockoutLabel(duration: settings.lockoutDuration)
        
        // Update UI state based on password protection setting
        updatePasswordProtectionUI()
    }

    @IBAction func sliderDidChange(_ sender: NSSlider) {
        let newTimeout = sender.doubleValue
        timeoutLabel.stringValue = "\(Int(newTimeout)) seconds"
        UserSettings.shared.inactivityTimeout = newTimeout
        
        // Notify the running activity monitor to update its interval
        (NSApplication.shared.delegate as? AppDelegate)?.activityMonitor.update(newInterval: newTimeout)
    }
    
    @IBAction func colorDidChange(_ sender: NSColorWell) {
        UserSettings.shared.matrixCharacterColor = sender.color
    }
    
    @IBAction func launchAtLoginDidChange(_ sender: NSSwitch) {
        LaunchAtLogin.isEnabled = (sender.state == .on)
    }
    
    // MARK: - Security Settings Actions
    
    @IBAction func passwordProtectionDidChange(_ sender: NSSwitch) {
        UserSettings.shared.enablePasswordProtection = (sender.state == .on)
        updatePasswordProtectionUI()
    }
    
    @IBAction func passwordDidChange(_ sender: NSSecureTextField) {
        UserSettings.shared.setPassword(sender.stringValue)
    }
    
    @IBAction func failedAttemptsDidChange(_ sender: NSStepper) {
        let attempts = Int(sender.doubleValue)
        UserSettings.shared.maxFailedAttempts = attempts
        failedAttemptsLabel.stringValue = "\(attempts)"
    }
    
    @IBAction func lockoutDurationDidChange(_ sender: NSSlider) {
        let duration = sender.doubleValue
        UserSettings.shared.lockoutDuration = duration
        updateLockoutLabel(duration: duration)
    }
    
    // MARK: - Helper Methods
    
    private func updatePasswordProtectionUI() {
        let isEnabled = passwordProtectionSwitch.state == .on
        passwordField.isEnabled = isEnabled
        failedAttemptsStepper.isEnabled = isEnabled
        lockoutSlider.isEnabled = isEnabled
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
