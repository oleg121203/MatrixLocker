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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMatrixBackground()
        setupUnlockInterface()
        updateInterface()
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
        // Create container view for unlock interface
        let containerView = NSView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Message label
        messageLabel = NSTextField()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.isEditable = false
        messageLabel.isBordered = false
        messageLabel.backgroundColor = .clear
        messageLabel.textColor = .white
        messageLabel.font = NSFont.systemFont(ofSize: 16)
        messageLabel.alignment = .center
        messageLabel.stringValue = "Enter password to unlock"
        
        // Password field
        passwordField = NSSecureTextField()
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.font = NSFont.systemFont(ofSize: 14)
        passwordField.target = self
        passwordField.action = #selector(passwordEntered)
        
        // Unlock button
        unlockButton = NSButton()
        unlockButton.translatesAutoresizingMaskIntoConstraints = false
        unlockButton.title = "Unlock"
        unlockButton.bezelStyle = .rounded
        unlockButton.target = self
        unlockButton.action = #selector(unlockButtonClicked)
        
        // Use System Auth button
        useSystemAuthButton = NSButton()
        useSystemAuthButton.translatesAutoresizingMaskIntoConstraints = false
        useSystemAuthButton.title = "Use Touch ID / Password"
        useSystemAuthButton.bezelStyle = .rounded
        useSystemAuthButton.target = self
        useSystemAuthButton.action = #selector(systemAuthButtonClicked)
        
        // Retry button (hidden initially)
        retryButton = NSButton()
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.title = "Try Again"
        retryButton.bezelStyle = .rounded
        retryButton.target = self
        retryButton.action = #selector(retryButtonClicked)
        retryButton.isHidden = true
        
        // Add subviews
        containerView.addSubview(messageLabel)
        containerView.addSubview(passwordField)
        containerView.addSubview(unlockButton)
        containerView.addSubview(useSystemAuthButton)
        containerView.addSubview(retryButton)
        
        self.view.addSubview(containerView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Container view centered
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 200),
            
            // Message label
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Password field
            passwordField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 30),
            
            // Unlock button
            unlockButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 15),
            unlockButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            unlockButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            unlockButton.heightAnchor.constraint(equalToConstant: 32),
            
            // System auth button
            useSystemAuthButton.topAnchor.constraint(equalTo: unlockButton.bottomAnchor, constant: 10),
            useSystemAuthButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            useSystemAuthButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            useSystemAuthButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Retry button
            retryButton.topAnchor.constraint(equalTo: useSystemAuthButton.bottomAnchor, constant: 10),
            retryButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            retryButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            retryButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func updateInterface() {
        let settings = UserSettings.shared
        let security = SecurityManager.shared
        
        // Check if locked out
        if security.isLockedOut() {
            let timeRemaining = security.timeRemainingInLockout()
            messageLabel.stringValue = "Too many failed attempts. Try again in \(security.formatTimeRemaining(timeRemaining))"
            passwordField.isEnabled = false
            unlockButton.isEnabled = false
            
            // Start timer to update countdown
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                if !security.isLockedOut() {
                    timer.invalidate()
                    self?.updateInterface()
                } else {
                    let remaining = security.timeRemainingInLockout()
                    self?.messageLabel.stringValue = "Too many failed attempts. Try again in \(security.formatTimeRemaining(remaining))"
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

    @objc private func passwordEntered() {
        unlockButtonClicked()
    }
    
    @objc private func unlockButtonClicked() {
        let inputPassword = passwordField.stringValue
        let result = SecurityManager.shared.attemptLogin(password: inputPassword)
        
        switch result {
        case .success:
            delegate?.didUnlockScreen()
        case .failed(let remaining), .lockedOut(_):
            messageLabel.stringValue = result.errorMessage
            messageLabel.textColor = .systemRed
            passwordField.stringValue = ""
            
            if case .lockedOut(_) = result {
                passwordField.isEnabled = false
                unlockButton.isEnabled = false
                
                // Update interface after a delay to refresh lockout status
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.updateInterface()
                }
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
                        SecurityManager.shared.attemptLogin(password: UserSettings.shared.lockPassword ?? "")
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
}
