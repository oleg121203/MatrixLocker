import Cocoa
import LocalAuthentication

protocol LockScreenDelegate: AnyObject {
    func didUnlockScreen()
}

class LockScreenViewController: NSViewController {
    weak var delegate: LockScreenDelegate?
    
    private var passwordField: NSSecureTextField!
    private var messageLabel: NSTextField!
    private var unlockButton: NSButton!
    private var retryButton: NSButton!
    private var useSystemAuthButton: NSButton!
    private var timeRemainingLabel: NSTextField!
    private var lockStartTime: Date?
    private var timeRemainingTimer: Timer?port LocalAuthentication

protocol LockScreenDelegate: AnyObject {
    func didUnlockScreen()
}

class LockScreenViewController: NSViewController {
    weak var delegate: LockScreenDelegate?
    
    private var passwordField: NSSecureTextField!
    private var messageLabel: NSTextField!
    private var unlockButton: NSButton!
    private var retryButton: NSButton!
    private var useSystemAuthButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lockStartTime = Date()
        setupMatrixBackground()
        setupUnlockInterface()
        updateInterface()
        setupTimeRemainingTimer()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        attemptSystemAuthentication()
    }

    private func setupMatrixBackground() {
        let matrixView = LockScreenView(frame: self.view.bounds)
        matrixView.autoresizingMask = [.width, .height]
        self.view.addSubview(matrixView, positioned: .below, relativeTo: nil)
    }
    
    private func setupUnlockInterface() {
        // Create main container with glass effect
        let containerView = NSVisualEffectView()
        containerView.material = .hudWindow
        containerView.blendingMode = .behindWindow
        containerView.state = .active
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create content view inside the glass container
        let contentView = NSView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Matrix-style title
        let titleLabel = NSTextField()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = UserSettings.shared.matrixCharacterColor
        titleLabel.font = NSFont(name: "Menlo", size: 24) ?? NSFont.monospacedSystemFont(ofSize: 24, weight: .bold)
        titleLabel.alignment = .center
        titleLabel.stringValue = "MATRIX LOCKED"
        
        // Message label with glow effect
        messageLabel = NSTextField()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.isEditable = false
        messageLabel.isBordered = false
        messageLabel.backgroundColor = .clear
        messageLabel.textColor = .white
        messageLabel.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.alignment = .center
        messageLabel.stringValue = "Activity limit reached - Enter authentication"
        
        // Modern password field with Matrix styling
        passwordField = NSSecureTextField()
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.font = NSFont.monospacedSystemFont(ofSize: 16, weight: .medium)
        passwordField.alignment = .center
        passwordField.target = self
        passwordField.action = #selector(passwordEntered)
        passwordField.placeholderString = "Enter password..."
        passwordField.wantsLayer = true
        passwordField.layer?.cornerRadius = 8
        passwordField.layer?.borderWidth = 2
        passwordField.layer?.borderColor = UserSettings.shared.matrixCharacterColor.cgColor
        passwordField.backgroundColor = NSColor.black.withAlphaComponent(0.7)
        passwordField.textColor = UserSettings.shared.matrixCharacterColor
        
        // Styled unlock button
        unlockButton = NSButton()
        unlockButton.translatesAutoresizingMaskIntoConstraints = false
        unlockButton.title = "UNLOCK"
        unlockButton.bezelStyle = .rounded
        unlockButton.font = NSFont.systemFont(ofSize: 14, weight: .bold)
        unlockButton.target = self
        unlockButton.action = #selector(unlockButtonClicked)
        unlockButton.wantsLayer = true
        unlockButton.layer?.cornerRadius = 6
        unlockButton.layer?.borderWidth = 1
        unlockButton.layer?.borderColor = UserSettings.shared.matrixCharacterColor.cgColor
        
        // Touch ID button
        useSystemAuthButton = NSButton()
        useSystemAuthButton.translatesAutoresizingMaskIntoConstraints = false
        useSystemAuthButton.title = "Use Touch ID / Face ID"
        useSystemAuthButton.bezelStyle = .rounded
        useSystemAuthButton.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        useSystemAuthButton.target = self
        useSystemAuthButton.action = #selector(systemAuthButtonClicked)
        useSystemAuthButton.wantsLayer = true
        useSystemAuthButton.layer?.cornerRadius = 6
        useSystemAuthButton.layer?.borderWidth = 1
        useSystemAuthButton.layer?.borderColor = NSColor.systemBlue.cgColor
        
        // Retry button
        retryButton = NSButton()
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.title = "Try Again"
        retryButton.bezelStyle = .rounded
        retryButton.target = self
        retryButton.action = #selector(retryButtonClicked)
        retryButton.isHidden = true
        
        // Time remaining label (conditional)
        timeRemainingLabel = NSTextField()
        timeRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        timeRemainingLabel.isEditable = false
        timeRemainingLabel.isBordered = false
        timeRemainingLabel.backgroundColor = .clear
        timeRemainingLabel.textColor = UserSettings.shared.matrixCharacterColor.withAlphaComponent(0.8)
        timeRemainingLabel.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        timeRemainingLabel.alignment = .center
        timeRemainingLabel.isHidden = !UserSettings.shared.showTimeRemaining
        
        // Add subviews
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(passwordField)
        contentView.addSubview(unlockButton)
        contentView.addSubview(useSystemAuthButton)
        contentView.addSubview(retryButton)
        contentView.addSubview(timeRemainingLabel)
        
        containerView.addSubview(contentView)
        self.view.addSubview(containerView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Container view centered
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 350),
            containerView.heightAnchor.constraint(equalToConstant: 280),
            
            // Content view fills container
            contentView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Message label
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Password field
            passwordField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 30),
            
            // Unlock button
            unlockButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 15),
            unlockButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            unlockButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            unlockButton.heightAnchor.constraint(equalToConstant: 32),
            
            // System auth button
            useSystemAuthButton.topAnchor.constraint(equalTo: unlockButton.bottomAnchor, constant: 10),
            useSystemAuthButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            useSystemAuthButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            useSystemAuthButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Time remaining label
            timeRemainingLabel.topAnchor.constraint(equalTo: useSystemAuthButton.bottomAnchor, constant: 10),
            timeRemainingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timeRemainingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Retry button
            retryButton.topAnchor.constraint(equalTo: timeRemainingLabel.bottomAnchor, constant: 5),
            retryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            retryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func updateInterface() {
        let settings = UserSettings.shared
        
        // Check if locked out
        if settings.isLockedOut() {
            let timeRemaining = settings.timeRemainingInLockout()
            messageLabel.stringValue = "Too many failed attempts. Try again in \(settings.formatTimeRemaining(timeRemaining))"
            passwordField.isEnabled = false
            unlockButton.isEnabled = false
            
            // Start timer to update countdown
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                if !settings.isLockedOut() {
                    timer.invalidate()
                    self?.updateInterface()
                } else {
                    let remaining = settings.timeRemainingInLockout()
                    self?.messageLabel.stringValue = "Too many failed attempts. Try again in \(settings.formatTimeRemaining(remaining))"
                }
            }
        } else {
            // Normal unlock interface
            if settings.enablePasswordProtection && settings.lockPassword != nil {
                messageLabel.stringValue = "Enter password to unlock"
                passwordField.isEnabled = true
                unlockButton.isEnabled = true
                passwordField.becomeFirstResponder()
            } else {
                messageLabel.stringValue = "Authentication required"
                passwordField.isEnabled = false
                unlockButton.isEnabled = false
            }
        }
    }

    private func setupTimeRemainingTimer() {
        guard UserSettings.shared.showTimeRemaining else { return }
        
        timeRemainingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        guard UserSettings.shared.showTimeRemaining,
              let startTime = lockStartTime else {
            timeRemainingLabel?.isHidden = true
            return
        }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        let totalLockTime = UserSettings.shared.inactivityTimeout
        let remainingTime = max(0, totalLockTime - elapsedTime)
        
        if remainingTime > 0 {
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60
            timeRemainingLabel?.stringValue = String(format: "Auto-unlock in: %02d:%02d", minutes, seconds)
            timeRemainingLabel?.isHidden = false
        } else {
            timeRemainingLabel?.stringValue = "Auto-unlock available"
            timeRemainingLabel?.isHidden = false
        }
    }
    
    // MARK: - Cleanup
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        timeRemainingTimer?.invalidate()
        timeRemainingTimer = nil
    }
    
    @objc private func passwordEntered() {
        unlockButtonClicked()
    }
    
    @objc private func unlockButtonClicked() {
        let inputPassword = passwordField.stringValue
        let result = UserSettings.shared.attemptLogin(password: inputPassword)
        
        switch result {
        case .success:
            delegate?.didUnlockScreen()
        case .failed:
            messageLabel.stringValue = result.errorMessage
            messageLabel.textColor = .systemRed
            passwordField.stringValue = ""
        case .lockedOut(_):
            messageLabel.stringValue = result.errorMessage
            messageLabel.textColor = .systemRed
            passwordField.stringValue = ""
            passwordField.isEnabled = false
            unlockButton.isEnabled = false
            
            // Update interface after a delay to refresh lockout status
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateInterface()
            }
        }
    }
    
    @objc private func systemAuthButtonClicked() {
        attemptSystemAuthentication()
    }
    
    @objc private func retryButtonClicked() {
        retryButton.isHidden = true
        attemptSystemAuthentication()
    }

    private func attemptSystemAuthentication() {
        let context = LAContext()
        var error: NSError?
        let reason = "Authenticate to unlock your session."

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        // Reset failed attempts on successful system auth
                        _ = UserSettings.shared.attemptLogin(password: UserSettings.shared.lockPassword ?? "")
                        self?.delegate?.didUnlockScreen()
                    } else {
                        self?.retryButton.isHidden = false
                        self?.messageLabel.stringValue = "System authentication failed. Use password or try again."
                        self?.messageLabel.textColor = .systemOrange
                    }
                }
            }
        } else {
            retryButton.isHidden = false
            messageLabel.stringValue = "System authentication not available. Use password."
            messageLabel.textColor = .systemYellow
        }
    }
}
