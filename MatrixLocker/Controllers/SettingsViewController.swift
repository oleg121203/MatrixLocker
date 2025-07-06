import Cocoa

/// View controller responsible for managing the application's settings interface.
/// It handles user interaction with the General, Matrix, and Security tabs,
/// updates UI elements based on current settings, and applies changes to persistent storage.
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

    /// Called after the controller's view is loaded into memory.
    /// Sets up UI elements with stored settings values and asserts all IBOutlets are connected.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assert all IBOutlet connections to prevent runtime issues.
        assert(launchAtLoginSwitch != nil, "launchAtLoginSwitch IBOutlet is not connected!")
        assert(hideFromDockSwitch != nil, "hideFromDockSwitch IBOutlet is not connected!")
        assert(startMinimizedSwitch != nil, "startMinimizedSwitch IBOutlet is not connected!")
        
        assert(characterColorWell != nil, "characterColorWell IBOutlet is not connected!")
        assert(animationSpeedSlider != nil, "animationSpeedSlider IBOutlet is not connected!")
        assert(animationSpeedLabel != nil, "animationSpeedLabel IBOutlet is not connected!")
        assert(densitySlider != nil, "densitySlider IBOutlet is not connected!")
        assert(densityLabel != nil, "densityLabel IBOutlet is not connected!")
        assert(soundEffectsSwitch != nil, "soundEffectsSwitch IBOutlet is not connected!")
        
        assert(automaticLockSwitch != nil, "automaticLockSwitch IBOutlet is not connected!")
        assert(timeoutSlider != nil, "timeoutSlider IBOutlet is not connected!")
        assert(timeoutLabel != nil, "timeoutLabel IBOutlet is not connected!")
        assert(passwordProtectionSwitch != nil, "passwordProtectionSwitch IBOutlet is not connected!")
        assert(passwordField != nil, "passwordField IBOutlet is not connected!")
        assert(setPasswordButton != nil, "setPasswordButton IBOutlet is not connected!")
        assert(maxAttemptsStepper != nil, "maxAttemptsStepper IBOutlet is not connected!")
        assert(maxAttemptsLabel != nil, "maxAttemptsLabel IBOutlet is not connected!")
        assert(lockoutDurationSlider != nil, "lockoutDurationSlider IBOutlet is not connected!")
        assert(lockoutDurationLabel != nil, "lockoutDurationLabel IBOutlet is not connected!")
        
        // Accessibility Setup
        
        // General Tab Accessibility
        launchAtLoginSwitch.setAccessibilityLabel("Launch at Login")
        launchAtLoginSwitch.setAccessibilityValue(launchAtLoginSwitch.state == .on ? "Enabled" : "Disabled")
        launchAtLoginSwitch.setAccessibilityHint("Toggle to launch the application automatically when you log in.")
        launchAtLoginSwitch.setAccessibilityIdentifier("launchAtLoginSwitch")
        launchAtLoginSwitch.toolTip = NSLocalizedString("Enable or disable launch at login", comment: "")
        
        hideFromDockSwitch.setAccessibilityLabel("Hide From Dock")
        hideFromDockSwitch.setAccessibilityValue(hideFromDockSwitch.state == .on ? "Enabled" : "Disabled")
        hideFromDockSwitch.setAccessibilityHint("Toggle to hide the application icon from the Dock.")
        hideFromDockSwitch.setAccessibilityIdentifier("hideFromDockSwitch")
        hideFromDockSwitch.toolTip = NSLocalizedString("Show or hide the app icon in the Dock", comment: "")
        
        startMinimizedSwitch.setAccessibilityLabel("Start Minimized")
        startMinimizedSwitch.setAccessibilityValue(startMinimizedSwitch.state == .on ? "Enabled" : "Disabled")
        startMinimizedSwitch.setAccessibilityHint("Toggle to start the application minimized.")
        startMinimizedSwitch.setAccessibilityIdentifier("startMinimizedSwitch")
        startMinimizedSwitch.toolTip = NSLocalizedString("Start the application minimized on launch", comment: "")
        
        // Matrix Tab Accessibility
        characterColorWell.setAccessibilityLabel("Character Color")
        characterColorWell.setAccessibilityValue("Selected color")
        characterColorWell.setAccessibilityHint("Select the color of the matrix characters.")
        characterColorWell.setAccessibilityIdentifier("characterColorWell")
        
        animationSpeedSlider.setAccessibilityLabel("Animation Speed")
        animationSpeedSlider.setAccessibilityValue(String(format: "%.1fx", animationSpeedSlider.doubleValue))
        animationSpeedSlider.setAccessibilityHint("Adjust the speed of the matrix animation.")
        animationSpeedSlider.setAccessibilityIdentifier("animationSpeedSlider")
        
        animationSpeedLabel.setAccessibilityLabel("Animation Speed Value")
        animationSpeedLabel.setAccessibilityValue(animationSpeedLabel.stringValue)
        animationSpeedLabel.setAccessibilityHint("Displays the current animation speed.")
        animationSpeedLabel.setAccessibilityIdentifier("animationSpeedLabel")
        
        densitySlider.setAccessibilityLabel("Character Density")
        densitySlider.setAccessibilityValue(String(format: "%.0f%%", densitySlider.doubleValue * 100))
        densitySlider.setAccessibilityHint("Adjust the density of matrix characters on screen.")
        densitySlider.setAccessibilityIdentifier("densitySlider")
        
        densityLabel.setAccessibilityLabel("Character Density Value")
        densityLabel.setAccessibilityValue(densityLabel.stringValue)
        densityLabel.setAccessibilityHint("Displays the current character density percentage.")
        densityLabel.setAccessibilityIdentifier("densityLabel")
        
        soundEffectsSwitch.setAccessibilityLabel("Sound Effects")
        soundEffectsSwitch.setAccessibilityValue(soundEffectsSwitch.state == .on ? "Enabled" : "Disabled")
        soundEffectsSwitch.setAccessibilityHint("Toggle sound effects for matrix animation.")
        soundEffectsSwitch.setAccessibilityIdentifier("soundEffectsSwitch")
        soundEffectsSwitch.toolTip = NSLocalizedString("Enable or disable sound effects", comment: "")
        
        // Security Tab Accessibility
        automaticLockSwitch.setAccessibilityLabel("Automatic Lock")
        automaticLockSwitch.setAccessibilityValue(automaticLockSwitch.state == .on ? "Enabled" : "Disabled")
        automaticLockSwitch.setAccessibilityHint("Toggle to enable automatic locking after inactivity.")
        automaticLockSwitch.setAccessibilityIdentifier("automaticLockSwitch")
        automaticLockSwitch.toolTip = NSLocalizedString("Enable or disable automatic screen lock", comment: "")
        
        timeoutSlider.setAccessibilityLabel("Inactivity Timeout")
        timeoutSlider.setAccessibilityValue(String(format: "%.0f seconds", timeoutSlider.doubleValue))
        timeoutSlider.setAccessibilityHint("Adjust the timeout period before automatic lock activates.")
        timeoutSlider.setAccessibilityIdentifier("timeoutSlider")
        
        timeoutLabel.setAccessibilityLabel("Inactivity Timeout Value")
        timeoutLabel.setAccessibilityValue(timeoutLabel.stringValue)
        timeoutLabel.setAccessibilityHint("Displays the current inactivity timeout duration.")
        timeoutLabel.setAccessibilityIdentifier("timeoutLabel")
        
        passwordProtectionSwitch.setAccessibilityLabel("Password Protection")
        passwordProtectionSwitch.setAccessibilityValue(passwordProtectionSwitch.state == .on ? "Enabled" : "Disabled")
        passwordProtectionSwitch.setAccessibilityHint("Toggle to enable or disable password protection.")
        passwordProtectionSwitch.setAccessibilityIdentifier("passwordProtectionSwitch")
        passwordProtectionSwitch.toolTip = NSLocalizedString("Enable or disable password protection for unlocking", comment: "")
        
        passwordField.setAccessibilityLabel("Enter Password")
        passwordField.setAccessibilityValue("")
        passwordField.setAccessibilityHint("Enter a new unlock password.")
        passwordField.setAccessibilityIdentifier("passwordField")
        
        setPasswordButton.setAccessibilityLabel("Set Password")
        setPasswordButton.setAccessibilityHint("Click to set or change the unlock password.")
        setPasswordButton.setAccessibilityIdentifier("setPasswordButton")
        setPasswordButton.toolTip = NSLocalizedString("Set or change the unlock password", comment: "")
        
        maxAttemptsStepper.setAccessibilityLabel("Maximum Failed Attempts")
        maxAttemptsStepper.setAccessibilityValue("\(maxAttemptsStepper.integerValue) attempts")
        maxAttemptsStepper.setAccessibilityHint("Set the maximum number of allowed failed unlock attempts.")
        maxAttemptsStepper.setAccessibilityIdentifier("maxAttemptsStepper")
        
        maxAttemptsLabel.setAccessibilityLabel("Maximum Failed Attempts Value")
        maxAttemptsLabel.setAccessibilityValue(maxAttemptsLabel.stringValue)
        maxAttemptsLabel.setAccessibilityHint("Displays the current maximum failed attempts allowed.")
        maxAttemptsLabel.setAccessibilityIdentifier("maxAttemptsLabel")
        
        lockoutDurationSlider.setAccessibilityLabel("Lockout Duration")
        let lockoutMinutes = Int(lockoutDurationSlider.doubleValue / 60)
        lockoutDurationSlider.setAccessibilityValue("\(lockoutMinutes) minutes")
        lockoutDurationSlider.setAccessibilityHint("Set the duration of the lockout period after maximum failed attempts.")
        lockoutDurationSlider.setAccessibilityIdentifier("lockoutDurationSlider")
        
        lockoutDurationLabel.setAccessibilityLabel("Lockout Duration Value")
        lockoutDurationLabel.setAccessibilityValue(lockoutDurationLabel.stringValue)
        lockoutDurationLabel.setAccessibilityHint("Displays the current lockout duration in minutes.")
        lockoutDurationLabel.setAccessibilityIdentifier("lockoutDurationLabel")
        
        // Tooltips provide important contextual information for all users,
        // especially benefiting users with accessibility needs by clarifying control functions.
        // They complement accessibility labels and hints to improve usability and user experience.
        
        // Load settings for General tab controls
        loadSettings()
        
        // Load settings for Matrix tab controls
        
        // Load settings for Security tab controls
        
        // Update UI elements' enabled states based on settings
        updateUIState()
        
        // Set accessibility elements order for better navigation
        setAccessibilityElementsOrder()
    }
    
    /// Defines the order in which accessibility elements are traversed in each tab.
    /// This improves keyboard and assistive technology navigation.
    private func setAccessibilityElementsOrder() {
        // General Tab order
        let generalTabElements: [Any] = [
            launchAtLoginSwitch!,
            hideFromDockSwitch!,
            startMinimizedSwitch!
        ]
        view.setAccessibilityChildren(generalTabElements)
        
        // Matrix Tab order
        let matrixTabElements: [Any] = [
            characterColorWell!,
            animationSpeedSlider!,
            animationSpeedLabel!,
            densitySlider!,
            densityLabel!,
            soundEffectsSwitch!
        ]
        // Note: You would set these in the appropriate container for the Matrix tab
        
        // Security Tab order
        let securityTabElements: [Any] = [
            automaticLockSwitch!,
            timeoutSlider!,
            timeoutLabel!,
            passwordProtectionSwitch!,
            passwordField!,
            setPasswordButton!,
            maxAttemptsStepper!,
            maxAttemptsLabel!,
            lockoutDurationSlider!,
            lockoutDurationLabel!
        ]
        // Note: You would set these in the appropriate container for the Security tab
        
        // If tabs are separate views/containers, set their accessibilityChildren accordingly.
        // Here we just demonstrate the method existence and concept.
    }
    
    // MARK: - Settings Loading and Saving
    
    /// Loads current settings from UserSettings singleton and updates UI accordingly.
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
        
        // Update accessibility values after loading
        updateAccessibilityValues()
    }
    
    /// Updates accessibilityValue properties to reflect current UI states and values.
    private func updateAccessibilityValues() {
        launchAtLoginSwitch.setAccessibilityValue(launchAtLoginSwitch.state == .on ? "Enabled" : "Disabled")
        hideFromDockSwitch.setAccessibilityValue(hideFromDockSwitch.state == .on ? "Enabled" : "Disabled")
        startMinimizedSwitch.setAccessibilityValue(startMinimizedSwitch.state == .on ? "Enabled" : "Disabled")
        
        characterColorWell.setAccessibilityValue("Selected color")
        animationSpeedSlider.setAccessibilityValue(String(format: "%.1fx", animationSpeedSlider.doubleValue))
        animationSpeedLabel.setAccessibilityValue(animationSpeedLabel.stringValue)
        densitySlider.setAccessibilityValue(String(format: "%.0f%%", densitySlider.doubleValue * 100))
        densityLabel.setAccessibilityValue(densityLabel.stringValue)
        soundEffectsSwitch.setAccessibilityValue(soundEffectsSwitch.state == .on ? "Enabled" : "Disabled")
        
        automaticLockSwitch.setAccessibilityValue(automaticLockSwitch.state == .on ? "Enabled" : "Disabled")
        timeoutSlider.setAccessibilityValue(String(format: "%.0f seconds", timeoutSlider.doubleValue))
        timeoutLabel.setAccessibilityValue(timeoutLabel.stringValue)
        passwordProtectionSwitch.setAccessibilityValue(passwordProtectionSwitch.state == .on ? "Enabled" : "Disabled")
        maxAttemptsStepper.setAccessibilityValue("\(maxAttemptsStepper.integerValue) attempts")
        maxAttemptsLabel.setAccessibilityValue(maxAttemptsLabel.stringValue)
        let lockoutMinutes = Int(lockoutDurationSlider.doubleValue / 60)
        lockoutDurationSlider.setAccessibilityValue("\(lockoutMinutes) minutes")
        lockoutDurationLabel.setAccessibilityValue(lockoutDurationLabel.stringValue)
    }
    
    /// Updates the enabled/disabled state of UI controls based on current settings.
    private func updateUIState() {
        let settings = UserSettings.shared
        let passwordProtectionEnabled = settings.enablePasswordProtection
        
        // Enable/disable controls based on password protection status
        passwordField.isEnabled = passwordProtectionEnabled
        setPasswordButton.isEnabled = passwordProtectionEnabled
        maxAttemptsStepper.isEnabled = passwordProtectionEnabled
        lockoutDurationSlider.isEnabled = passwordProtectionEnabled
        
        // Enable/disable controls based on automatic lock status
        let automaticLockEnabled = settings.enableAutomaticLock
        timeoutSlider.isEnabled = automaticLockEnabled
        
        updateLabels()
        
        // Update accessibility values and hints after state changes
        updateAccessibilityValues()
    }
    
    /// Updates the textual labels that display the current setting values.
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
    
    /// Called when any setting UI element is changed by the user.
    /// Updates the UserSettings singleton and posts notifications accordingly.
    /// - Parameter sender: The UI control that triggered the change.
    @IBAction func settingDidChange(_ sender: Any) {
        let settings = UserSettings.shared
        
        switch sender {
        case launchAtLoginSwitch:
            LaunchAtLogin.isEnabled = launchAtLoginSwitch.state == .on
            launchAtLoginSwitch.setAccessibilityValue(launchAtLoginSwitch.state == .on ? "Enabled" : "Disabled")
            announceAccessibilityChange("Launch at Login \(launchAtLoginSwitch.state == .on ? "enabled" : "disabled")")
            
        case hideFromDockSwitch:
            settings.hideFromDock = hideFromDockSwitch.state == .on
            hideFromDockSwitch.setAccessibilityValue(hideFromDockSwitch.state == .on ? "Enabled" : "Disabled")
            announceAccessibilityChange("Hide From Dock \(hideFromDockSwitch.state == .on ? "enabled" : "disabled")")
            
        case startMinimizedSwitch:
            settings.startMinimized = startMinimizedSwitch.state == .on
            startMinimizedSwitch.setAccessibilityValue(startMinimizedSwitch.state == .on ? "Enabled" : "Disabled")
            announceAccessibilityChange("Start Minimized \(startMinimizedSwitch.state == .on ? "enabled" : "disabled")")
            
        case characterColorWell:
            settings.matrixCharacterColor = characterColorWell.color
            announceAccessibilityChange("Character color changed")
            
        case animationSpeedSlider:
            settings.matrixAnimationSpeed = animationSpeedSlider.doubleValue
            animationSpeedSlider.setAccessibilityValue(String(format: "%.1fx", animationSpeedSlider.doubleValue))
            updateLabels()
            announceAccessibilityChange("Animation speed set to \(String(format: "%.1fx", animationSpeedSlider.doubleValue))")
            
        case densitySlider:
            settings.matrixDensity = densitySlider.doubleValue
            densitySlider.setAccessibilityValue(String(format: "%.0f%%", densitySlider.doubleValue * 100))
            updateLabels()
            announceAccessibilityChange("Character density set to \(String(format: "%.0f%%", densitySlider.doubleValue * 100))")
            
        case soundEffectsSwitch:
            settings.matrixSoundEffects = soundEffectsSwitch.state == .on
            soundEffectsSwitch.setAccessibilityValue(soundEffectsSwitch.state == .on ? "Enabled" : "Disabled")
            announceAccessibilityChange("Sound effects \(soundEffectsSwitch.state == .on ? "enabled" : "disabled")")
            
        case automaticLockSwitch:
            settings.enableAutomaticLock = automaticLockSwitch.state == .on
            automaticLockSwitch.setAccessibilityValue(automaticLockSwitch.state == .on ? "Enabled" : "Disabled")
            updateUIState()
            announceAccessibilityChange("Automatic lock \(automaticLockSwitch.state == .on ? "enabled" : "disabled")")
            if settings.enableAutomaticLock {
                NotificationCenter.default.post(name: Notifications.startMonitoring, object: nil)
            } else {
                NotificationCenter.default.post(name: Notifications.stopMonitoring, object: nil)
            }
            
        case timeoutSlider:
            settings.inactivityTimeout = timeoutSlider.doubleValue
            timeoutSlider.setAccessibilityValue(String(format: "%.0f seconds", timeoutSlider.doubleValue))
            updateLabels()
            announceAccessibilityChange("Inactivity timeout set to \(String(format: "%.0f seconds", timeoutSlider.doubleValue))")
            
        case passwordProtectionSwitch:
            settings.enablePasswordProtection = passwordProtectionSwitch.state == .on
            passwordProtectionSwitch.setAccessibilityValue(passwordProtectionSwitch.state == .on ? "Enabled" : "Disabled")
            updateUIState()
            announceAccessibilityChange("Password protection \(passwordProtectionSwitch.state == .on ? "enabled" : "disabled")")
            if !settings.enablePasswordProtection {
                settings.setPassword(nil)
                announceAccessibilityChange("Password protection disabled and password cleared")
            }
            
        case maxAttemptsStepper:
            settings.maxFailedAttempts = maxAttemptsStepper.integerValue
            maxAttemptsStepper.setAccessibilityValue("\(maxAttemptsStepper.integerValue) attempts")
            updateLabels()
            announceAccessibilityChange("Maximum failed attempts set to \(maxAttemptsStepper.integerValue)")
            
        case lockoutDurationSlider:
            settings.lockoutDuration = lockoutDurationSlider.doubleValue
            let minutes = Int(lockoutDurationSlider.doubleValue / 60)
            lockoutDurationSlider.setAccessibilityValue("\(minutes) minutes")
            updateLabels()
            announceAccessibilityChange("Lockout duration set to \(minutes) minutes")
            
        default:
            break
        }
        
        NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
    }

    /// Called when the "Set Password" button is clicked.
    /// Validates the new password, confirms with the user, and updates the stored password if valid.
    /// - Parameter sender: The button that was clicked.
    @IBAction func setPasswordClicked(_ sender: NSButton) {
        let password = passwordField.stringValue
        
        // Check for empty password
        guard !password.isEmpty else {
            print("Password change error: Password field is empty.")
            showAlert(title: "Invalid Password",
                      message: "Please enter a password.",
                      style: .warning)
            announceAccessibilityChange("Password change failed: Password field is empty")
            return
        }
        
        // Check password length
        guard password.count >= 6 else {
            print("Password change error: Password is shorter than 6 characters.")
            showAlert(title: "Invalid Password",
                      message: "Password must be at least 6 characters long.",
                      style: .warning)
            announceAccessibilityChange("Password change failed: Password too short")
            return
        }
        
        // Check if password is different from the current one
        if let currentPassword = UserSettings.shared.lockPassword, currentPassword == password {
            print("Password change error: New password is the same as the current password.")
            showAlert(title: "Unchanged Password",
                      message: "The new password must be different from the current password.",
                      style: .warning)
            announceAccessibilityChange("Password change failed: New password matches current password")
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
                print("Password successfully updated.")
                self.showAlert(title: "Password Updated",
                               message: "The unlock password has been changed successfully.",
                               style: .informational)
                self.announceAccessibilityChange("Password changed successfully")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Updates the lockout duration label to display minutes.
    /// - Parameter duration: The lockout duration in seconds.
    private func updateLockoutLabel(duration: TimeInterval) {
        let minutes = Int(duration / 60)
        lockoutDurationLabel.stringValue = "\(minutes) min lockout"
    }
    
    /// Presents an alert with the given title, message, and style.
    /// - Parameters:
    ///   - title: The alert's title.
    ///   - message: The alert's informative message.
    ///   - style: The style of the alert.
    private func showAlert(title: String, message: String, style: NSAlert.Style) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    /// Posts an accessibility announcement for users with assistive technologies.
    /// - Parameter message: The message to be announced.
    private func announceAccessibilityChange(_ message: String) {
        NSAccessibility.post(element: self.view,
                             notification: .announcementRequested,
                             userInfo: [NSAccessibility.NotificationUserInfoKey.announcement: message,
                                        NSAccessibility.NotificationUserInfoKey.priority: NSAccessibilityPriorityLevel.high])
    }
}

