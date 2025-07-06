import Cocoa
import LocalAuthentication

/// Protocol to notify when the lock screen is successfully unlocked.
protocol LockScreenDelegate: AnyObject {
    func didUnlockScreen()
}

/// View controller responsible for displaying the lock screen with a matrix background,
/// handling password input, system biometric authentication, and lockout logic.
class LockScreenViewController: NSViewController {
    
    // MARK: - Delegate
    /// Delegate to notify about unlock events.
    weak var delegate: LockScreenDelegate?
    
    // MARK: - UI Elements
    
    /// Secure text field for password input.
    /// - Note: If this becomes an IBOutlet in the future, ensure to assert its connection in viewDidLoad for stability.
    private var passwordField: NSSecureTextField!
    
    /// Label to show messages to the user (instructions, errors, lockout info).
    private var messageLabel: NSTextField!
    
    /// Custom view displaying the animated matrix background.
    private var matrixView: LockScreenView!
    
    /// Button to trigger password unlock attempt.
    private var unlockButton: NSButton!
    
    /// Label to show password recovery hint after multiple failed attempts.
    /// TODO: Consider converting messageLabel to separate labels for error and hint messages for clarity.
    private var recoveryHintLabel: NSTextField?
    
    // MARK: - State
    
    /// Number of failed password attempts.
    private var failedAttempts = 0
    
    /// Indicates if the lock screen is currently locked.
    private var isLocked = true
    
    /// Timer to update lockout countdown message.
    private var lockoutTimer: Timer?

    // MARK: - Lifecycle
    
    /// Called after the controller's view is loaded into memory.
    /// Sets up the UI and attempts system biometric authentication.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the animated matrix background view.
        setupMatrixBackground()
        
        // Setup the password entry interface and related UI elements.
        setupUnlockInterface()
        
        // Assert UI elements exist for stability (if these become IBOutlets in the future).
        // This ensures that the UI is properly connected, preventing runtime crashes.
        assert(passwordField != nil, "passwordField must be connected and not nil")
        assert(messageLabel != nil, "messageLabel must be connected and not nil")
        assert(unlockButton != nil, "unlockButton must be connected and not nil")
        
        // Accessibility: Set accessibility labels, identifiers, values and hints
        // TODO: Localize accessibility labels if supporting multiple languages in the future
        passwordField.setAccessibilityLabel("Password Field")
        passwordField.setAccessibilityIdentifier("passwordField")
        passwordField.setAccessibilityValue("Password Input") // Added accessibilityValue
        
        messageLabel.setAccessibilityLabel("Unlock Message")
        messageLabel.setAccessibilityIdentifier("messageLabel")
        // messageLabel accessibilityValue not set because it changes dynamically
        
        unlockButton.setAccessibilityLabel("Unlock Button")
        unlockButton.setAccessibilityIdentifier("unlockButton")
        unlockButton.setAccessibilityValue("Unlock Button") // Added accessibilityValue
        unlockButton.setAccessibilityHelp("Unlocks the screen with your password") // Added accessibilityHelp
        
        // Set accessibility elements order for proper VoiceOver navigation
        setAccessibilityElementsOrder()
        
        // Attempt biometric authentication if enabled.
        attemptSystemAuthentication()
    }
    
    /// Called just before the view appears.
    /// Configures the window and starts matrix animation.
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // Set window level above screensaver to cover all other windows.
        view.window?.level = .screenSaver
        
        // Disable moving window by dragging background to prevent bypass.
        view.window?.isMovableByWindowBackground = false
        
        // Make password field first responder to receive keyboard input immediately.
        view.window?.makeFirstResponder(passwordField)
        
        // Start the matrix background animation.
        matrixView.startAnimation()
    }
    
    /// Called just before the view disappears.
    /// Stops the background animation for resource efficiency.
    override func viewWillDisappear() {
        super.viewWillDisappear()
        matrixView.stopAnimation()
    }

    // MARK: - Setup Methods
    
    /// Sets up the matrix animated background view.
    private func setupMatrixBackground() {
        matrixView = LockScreenView(frame: self.view.bounds)
        matrixView.autoresizingMask = [.width, .height]
        view.addSubview(matrixView)
    }
    
    /// Sets up the password entry UI with a frosted glass container,
    /// message label, password field, and unlock button.
    private func setupUnlockInterface() {
        // Container for the unlock UI with fixed size.
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 150))
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Visual effect view to create a frosted glass background.
        let blurView = NSVisualEffectView(frame: container.bounds)
        blurView.blendingMode = .behindWindow
        blurView.material = .dark
        blurView.state = .active
        blurView.autoresizingMask = [.width, .height]
        container.addSubview(blurView)
        
        // Message label showing instructions or error messages.
        messageLabel = NSTextField(labelWithString: "Enter Password to Unlock")
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.alignment = .center
        messageLabel.textColor = .white
        container.addSubview(messageLabel)
        
        // Password input field.
        passwordField = NSSecureTextField(frame: .zero)
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.placeholderString = "Password"
        passwordField.target = self
        passwordField.action = #selector(passwordEntered)
        container.addSubview(passwordField)
        
        // Unlock button.
        unlockButton = NSButton(title: "Unlock", target: self, action: #selector(unlockButtonClicked))
        unlockButton.translatesAutoresizingMaskIntoConstraints = false
        unlockButton.bezelStyle = .rounded
        container.addSubview(unlockButton)
        
        // Add container to main view.
        view.addSubview(container)
        
        // Layout constraints for container and its subviews.
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalToConstant: 300),
            container.heightAnchor.constraint(equalToConstant: 150),
            
            messageLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            passwordField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 15),
            passwordField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            
            unlockButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 15),
            unlockButton.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        // Setup recovery hint label, initially hidden.
        let recoveryHint = NSTextField(labelWithString: "")
        recoveryHint.translatesAutoresizingMaskIntoConstraints = false
        recoveryHint.alignment = .center
        recoveryHint.textColor = .systemYellow
        recoveryHint.isHidden = true
        container.addSubview(recoveryHint)
        recoveryHintLabel = recoveryHint
        
        NSLayoutConstraint.activate([
            recoveryHint.topAnchor.constraint(equalTo: unlockButton.bottomAnchor, constant: 10),
            recoveryHint.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            recoveryHint.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])
        
        // TODO: Accessibility improvements - assign accessibility labels, hints and traits to UI elements.
    }
    
    // MARK: - Accessibility
    
    /// Sets the accessibility elements order for proper VoiceOver navigation.
    private func setAccessibilityElementsOrder() {
        // Ensures that VoiceOver navigates first to password field, then unlock button, then message label.
        view.setAccessibilityChildren([passwordField!, unlockButton!, messageLabel!])
    }
    
    // MARK: - Actions
    
    /// Called when Return key pressed inside password field.
    @objc private func passwordEntered() {
        checkPassword()
    }

    /// Called when the Unlock button is clicked.
    @objc private func unlockButtonClicked() {
        checkPassword()
    }
    
    // MARK: - Password Handling
    
    /// Checks the entered password against stored credentials and updates UI accordingly.
    private func checkPassword() {
        let password = passwordField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If the password field is empty, show red highlight, shake, and prompt.
        if password.isEmpty {
            incrementFailedAttempts()
            showPasswordFieldError(message: "Password cannot be empty.")
            print("[LockScreen] Empty password entered.")
            postAccessibilityAnnouncement(message: "Password cannot be empty.")
            return
        }
        
        let result = UserSettings.shared.attemptLogin(password: password)
        
        switch result {
        case .success:
            // Reset UI state.
            resetLockoutState()
            
            // Reset failed attempts count.
            failedAttempts = 0
            
            // Play success sound and notify delegate.
            SoundManager.shared.play(effect: .unlock)
            print("[LockScreen] Unlock successful.")
            delegate?.didUnlockScreen()
            
        case .failed(let attemptsRemaining):
            incrementFailedAttempts()
            let errorMessage = "Incorrect password. \(attemptsRemaining) attempts remaining."
            showPasswordFieldError(message: errorMessage)
            SoundManager.shared.play(effect: .failedAttempt)
            shakeWindow()
            print("[LockScreen] Incorrect password. Attempts remaining: \(attemptsRemaining)")
            
            // Accessibility announcement for error message
            postAccessibilityAnnouncement(message: errorMessage)
            
            // Show recovery hint after 3 failed attempts.
            if failedAttempts >= 3 {
                showRecoveryHint()
            }
            
        case .lockedOut(let timeRemaining):
            SoundManager.shared.play(effect: .failedAttempt)
            shakeWindow()
            messageLabel.textColor = .systemRed
            updateLockoutMessage(timeRemaining: timeRemaining)
            passwordField.isEnabled = false
            unlockButton.isEnabled = false
            startLockoutTimer()
            let lockoutMessage = "Too many failed attempts. Try again in \(UserSettings.shared.formatTimeRemaining(timeRemaining))."
            postAccessibilityAnnouncement(message: lockoutMessage)
            print("[LockScreen] User locked out for \(timeRemaining) seconds.")
        }
    }
    
    /// Posts an accessibility announcement for VoiceOver users.
    ///
    /// - Parameter message: The message to announce.
    private func postAccessibilityAnnouncement(message: String) {
        // Post accessibility notification to announce messages
        if let element = self.view.window?.contentView {
            NSAccessibility.post(element: element, notification: .announcementRequested)
            // Use NSAccessibility.Notification.announcementRequested with userInfo
            let userInfo: [NSAccessibility.NotificationUserInfoKey: Any] = [.announcement: message, .priority: NSAccessibilityPriorityLevel.high]
            NSAccessibility.post(element: element, notification: .announcementRequested, userInfo: userInfo)
        }
    }
    
    /// Increments the failed attempts counter.
    private func incrementFailedAttempts() {
        failedAttempts += 1
    }
    
    /// Highlights password field red, updates message label and shakes the window.
    ///
    /// - Parameter message: The message to show in the message label.
    private func showPasswordFieldError(message: String) {
        // Red background highlight for password field.
        passwordField.wantsLayer = true
        passwordField.layer?.backgroundColor = NSColor.systemRed.withAlphaComponent(0.3).cgColor
        
        // Update message label color and text.
        messageLabel.textColor = .systemRed
        messageLabel.stringValue = message
        
        // Clear password input.
        passwordField.stringValue = ""
        
        // Shake window for user feedback.
        shakeWindow()
    }
    
    /// Shows a hint to the user for password recovery after multiple failed attempts.
    private func showRecoveryHint() {
        recoveryHintLabel?.stringValue = "Forgot your password? Visit the settings to reset it."
        recoveryHintLabel?.isHidden = false
        // TODO: Consider adding a button or link here for direct password recovery flow.
    }
    
    /// Clears the password field error state (background color and hint), resets messages.
    private func clearPasswordFieldError() {
        passwordField.layer?.backgroundColor = NSColor.clear.cgColor
        recoveryHintLabel?.isHidden = true
        
        // Reset message label color and text.
        messageLabel.textColor = .white
        messageLabel.stringValue = "Enter Password to Unlock"
    }

    // MARK: - Lockout Handling
    
    /// Updates the message label with the remaining lockout time.
    /// - Parameter timeRemaining: The remaining lockout time in seconds.
    private func updateLockoutMessage(timeRemaining: TimeInterval) {
        let formattedTime = UserSettings.shared.formatTimeRemaining(timeRemaining)
        messageLabel.stringValue = "Too many failed attempts. Try again in \(formattedTime)."
    }
    
    /// Starts or restarts the timer that updates the lockout message every second.
    private func startLockoutTimer() {
        lockoutTimer?.invalidate()
        lockoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            if let remaining = UserSettings.shared.timeRemainingInLockout(), remaining > 0 {
                self?.updateLockoutMessage(timeRemaining: remaining)
            } else {
                timer.invalidate()
                self?.resetLockoutState()
                print("[LockScreen] Lockout ended, user can attempt login again.")
            }
        }
    }
    
    /// Resets the UI and state after lockout end or successful unlock.
    private func resetLockoutState() {
        clearPasswordFieldError()
        passwordField.isEnabled = true
        unlockButton.isEnabled = true
        passwordField.stringValue = ""
        recoveryHintLabel?.isHidden = true
        failedAttempts = 0
        
        // Refocus password field for immediate input.
        view.window?.makeFirstResponder(passwordField)
    }

    // MARK: - Biometric Authentication
    
    /// Attempts to authenticate the user using system biometrics if enabled.
    private func attemptSystemAuthentication() {
        guard UserSettings.shared.enablePasswordProtection else {
            print("[LockScreen] Password protection disabled, unlocking immediately.")
            delegate?.didUnlockScreen()
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Unlock MatrixLocker") { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        print("[LockScreen] Biometric authentication successful.")
                        self?.delegate?.didUnlockScreen()
                    } else {
                        print("[LockScreen] Biometric authentication failed or canceled.")
                    }
                }
            }
        } else {
            if let error = error {
                print("[LockScreen] Biometric authentication unavailable: \(error.localizedDescription)")
            } else {
                print("[LockScreen] Biometric authentication not available on this device.")
            }
        }
    }
    
    // MARK: - Animations
    
    /// Applies a shake animation to the window's content view to indicate an error.
    private func shakeWindow() {
        guard let contentLayer = self.view.window?.contentView?.layer else { return }
        
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        contentLayer.add(animation, forKey: "shake")
    }
    
    // TODO: Consider adding accessibility notifications for error messages and focus changes.
}
