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

    // MARK: - Properties
    
    private var currentViewController: NSViewController?
    private var sidebarButtons: [NSButton] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        updateUIState()
    }
    
    // MARK: - Settings Loading and Saving
    
    private func loadSettings() {
        let settings = UserSettings.shared
        
        // General Settings
        launchAtLoginSwitch.state = LaunchAtLogin.isEnabled ? .on : .off
        hideFromDockSwitch.state = settings.hideFromDock ? .on : .off
        startMinimizedSwitch.state = settings.startMinimized ? .on : .off
        
        // Matrix Settings
        characterColorWell.color = settings.matrixCharacterColor
        animationSpeedSlider.doubleValue = settings.matrixAnimationSpeed
        densitySlider.doubleValue = settings.matrixDensity
        soundEffectsSwitch.state = settings.matrixSoundEffects ? .on : .off
        
        // Security Settings
        automaticLockSwitch.state = settings.enableAutomaticLock ? .on : .off
        timeoutSlider.doubleValue = settings.inactivityTimeout
        passwordProtectionSwitch.state = settings.enablePasswordProtection ? .on : .off
        maxAttemptsStepper.integerValue = settings.maxFailedAttempts
        lockoutDurationSlider.doubleValue = settings.lockoutDuration
        
        updateLabels()
    }
    
    private func updateUIState() {
        let settings = UserSettings.shared
        let passwordProtectionEnabled = settings.enablePasswordProtection
        
        // Enable/disable controls based on password protection
        passwordField.isEnabled = passwordProtectionEnabled
        setPasswordButton.isEnabled = passwordProtectionEnabled
        maxAttemptsStepper.isEnabled = passwordProtectionEnabled
        lockoutDurationSlider.isEnabled = passwordProtectionEnabled
        
        // Enable/disable controls based on automatic lock
        let automaticLockEnabled = settings.enableAutomaticLock
        timeoutSlider.isEnabled = automaticLockEnabled
        
        updateLabels()
    }
    
    private func updateLabels() {
        let settings = UserSettings.shared
        
        // Update Matrix labels
        animationSpeedLabel.stringValue = String(format: "Animation Speed: %.1fx", settings.matrixAnimationSpeed)
        densityLabel.stringValue = String(format: "Character Density: %.0f%%", settings.matrixDensity * 100)
        
        // Update Security labels
        timeoutLabel.stringValue = String(format: "Lock after %.0f seconds of inactivity", settings.inactivityTimeout)
        maxAttemptsLabel.stringValue = String(format: "%d failed attempts allowed", settings.maxFailedAttempts)
        updateLockoutLabel(duration: settings.lockoutDuration)
    }
    
    // MARK: - Actions
    
    @IBAction func settingDidChange(_ sender: Any) {
        let settings = UserSettings.shared
        
        switch sender {
        case launchAtLoginSwitch:
            LaunchAtLogin.isEnabled = launchAtLoginSwitch.state == .on
            
        case hideFromDockSwitch:
            settings.hideFromDock = hideFromDockSwitch.state == .on
            
        case startMinimizedSwitch:
            settings.startMinimized = startMinimizedSwitch.state == .on
            
        case characterColorWell:
            settings.matrixCharacterColor = characterColorWell.color
            
        case animationSpeedSlider:
            settings.matrixAnimationSpeed = animationSpeedSlider.doubleValue
            updateLabels()
            
        case densitySlider:
            settings.matrixDensity = densitySlider.doubleValue
            updateLabels()
            
        case soundEffectsSwitch:
            settings.matrixSoundEffects = soundEffectsSwitch.state == .on
            
        case automaticLockSwitch:
            settings.enableAutomaticLock = automaticLockSwitch.state == .on
            updateUIState()
            if settings.enableAutomaticLock {
                NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
            } else {
                NotificationCenter.default.post(name: Notifications.stopMonitoring, object: nil)
            }
            
        case timeoutSlider:
            settings.inactivityTimeout = timeoutSlider.doubleValue
            updateLabels()
            
        case passwordProtectionSwitch:
            settings.enablePasswordProtection = passwordProtectionSwitch.state == .on
            updateUIState()
            if !settings.enablePasswordProtection {
                settings.setPassword(nil)
            }
            
        case maxAttemptsStepper:
            settings.maxFailedAttempts = maxAttemptsStepper.integerValue
            updateLabels()
            
        case lockoutDurationSlider:
            settings.lockoutDuration = lockoutDurationSlider.doubleValue
            updateLabels()
            
        default:
            break
        }
        
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }

    @IBAction func setPasswordClicked(_ sender: NSButton) {
        let password = passwordField.stringValue
        guard !password.isEmpty else {
            showAlert(title: "Invalid Password",
                     message: "Please enter a password.",
                     style: .warning)
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "Confirm Password Change"
        alert.informativeText = "Are you sure you want to change the unlock password?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Change Password")
        alert.addButton(withTitle: "Cancel")
        
        alert.beginSheetModal(for: self.view.window!) { response in
            if response == .alertFirstButtonReturn {
                UserSettings.shared.setPassword(password)
                self.passwordField.stringValue = ""
                self.showAlert(title: "Password Updated",
                             message: "The unlock password has been changed successfully.",
                             style: .informational)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateLockoutLabel(duration: TimeInterval) {
        let minutes = Int(duration / 60)
        lockoutDurationLabel.stringValue = "\(minutes) min lockout"
    }
    
    private func showAlert(title: String, message: String, style: NSAlert.Style) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
}
