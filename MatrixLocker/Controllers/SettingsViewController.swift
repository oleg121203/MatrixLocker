import Cocoa

class SettingsViewController: NSViewController {

    // MARK: - Outlets
    
    // General Tab
    @IBOutlet weak var launchAtLoginSwitch: NSSwitch!
    @IBOutlet weak var hideFromDockSwitch: NSSwitch!
    @IBOutlet weak var startMinimizedSwitch: NSSwitch!

    // Matrix Tab
    @IBOutlet weak var characterColorWell: NSColorWell!
    @IBOutlet weak var animationSpeedSlider: NSSlider!
    @IBOutlet weak var animationSpeedLabel: NSTextField!
    @IBOutlet weak var densitySlider: NSSlider!
    @IBOutlet weak var densityLabel: NSTextField!
    @IBOutlet weak var soundEffectsSwitch: NSSwitch!
    
    // Security Tab
    @IBOutlet weak var automaticLockSwitch: NSSwitch!
    @IBOutlet weak var timeoutSlider: NSSlider!
    @IBOutlet weak var timeoutLabel: NSTextField!
    @IBOutlet weak var passwordProtectionSwitch: NSSwitch!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var setPasswordButton: NSButton!
    @IBOutlet weak var maxAttemptsStepper: NSStepper!
    @IBOutlet weak var maxAttemptsLabel: NSTextField!
    @IBOutlet weak var lockoutDurationSlider: NSSlider!
    @IBOutlet weak var lockoutDurationLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        updateUIState()
    }
    
    private func loadSettings() {
        let settings = UserSettings.shared
        
        // General
        launchAtLoginSwitch.state = LaunchAtLogin.isEnabled ? .on : .off
        hideFromDockSwitch.state = settings.hideFromDock ? .on : .off
        startMinimizedSwitch.state = settings.startMinimized ? .on : .off
        
        // Matrix
        characterColorWell.color = settings.matrixCharacterColor
        animationSpeedSlider.doubleValue = settings.matrixAnimationSpeed
        densitySlider.doubleValue = settings.matrixDensity
        soundEffectsSwitch.state = settings.matrixSoundEffects ? .on : .off
        
        // Security
        automaticLockSwitch.state = settings.enableAutomaticLock ? .on : .off
        timeoutSlider.doubleValue = settings.inactivityTimeout
        passwordProtectionSwitch.state = settings.enablePasswordProtection ? .on : .off
        maxAttemptsStepper.integerValue = settings.maxFailedAttempts
        lockoutDurationSlider.doubleValue = settings.lockoutDuration
    }
    
    private func updateUIState() {

        // Matrix Labels
        animationSpeedLabel.stringValue = String(format: "%.1fx", animationSpeedSlider.doubleValue)
        densityLabel.stringValue = "\(Int(densitySlider.doubleValue * 100))%"
        
        // Security Labels & Controls
        timeoutLabel.stringValue = "Lock after \(Int(timeoutSlider.doubleValue)) seconds"
        maxAttemptsLabel.stringValue = "\(maxAttemptsStepper.integerValue) attempts"
        updateLockoutLabel(duration: lockoutDurationSlider.doubleValue)
        
        let autoLockEnabled = automaticLockSwitch.state == .on
        timeoutSlider.isEnabled = autoLockEnabled
        
        let passwordProtectionEnabled = passwordProtectionSwitch.state == .on
        passwordField.isEnabled = passwordProtectionEnabled
        setPasswordButton.isEnabled = passwordProtectionEnabled
        maxAttemptsStepper.isEnabled = passwordProtectionEnabled
        lockoutDurationSlider.isEnabled = passwordProtectionEnabled
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
                LaunchAtLogin.isEnabled = (launchAtLoginSwitch.state == .on)
            case hideFromDockSwitch:
                settings.hideFromDock = (hideFromDockSwitch.state == .on)
                showRestartAlert()
            case startMinimizedSwitch:
                settings.startMinimized = (startMinimizedSwitch.state == .on)
            
            // Matrix
            case characterColorWell:
                settings.matrixCharacterColor = characterColorWell.color
            case animationSpeedSlider:
                settings.matrixAnimationSpeed = animationSpeedSlider.doubleValue
            case densitySlider:
                settings.matrixDensity = densitySlider.doubleValue
            case soundEffectsSwitch:
                settings.matrixSoundEffects = (soundEffectsSwitch.state == .on)
                
            // Security
            case automaticLockSwitch:
                settings.enableAutomaticLock = (automaticLockSwitch.state == .on)
                // Trigger monitoring start/stop
                let notificationName = settings.enableAutomaticLock ? Notifications.startMonitoring : Notifications.stopMonitoring
                NotificationCenter.default.post(name: notificationName, object: nil)
            case timeoutSlider:
                settings.inactivityTimeout = timeoutSlider.doubleValue
            case passwordProtectionSwitch:
                settings.enablePasswordProtection = (passwordProtectionSwitch.state == .on)
            case maxAttemptsStepper:
                settings.maxFailedAttempts = maxAttemptsStepper.integerValue
            case lockoutDurationSlider:
                settings.lockoutDuration = lockoutDurationSlider.doubleValue
            default:
                break
            }
        }
        
        updateUIState()
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }

    @IBAction func setPasswordClicked(_ sender: NSButton) {
        let password = passwordField.stringValue
        if !password.isEmpty {
            UserSettings.shared.setPassword(password)
            passwordField.stringValue = "" // Clear field after setting
            showPasswordConfirmation()
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateLockoutLabel(duration: TimeInterval) {
        let minutes = Int(duration / 60)
        lockoutDurationLabel.stringValue = "\(minutes) min lockout"
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
}
