import Cocoa
import LocalAuthentication

protocol LockScreenDelegate: AnyObject {
    func didUnlockScreen()
}

class LockScreenViewController: NSViewController {
    weak var delegate: LockScreenDelegate?
    
    private var passwordField: NSSecureTextField!
    private var messageLabel: NSTextField!
    private var matrixView: LockScreenView!
    private var unlockButton: NSButton!
    private var failedAttempts = 0
    private var isLocked = true
    private var lockoutTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMatrixBackground()
        setupUnlockInterface()
        attemptSystemAuthentication()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.level = .screenSaver
        view.window?.isMovableByWindowBackground = false
        view.window?.makeFirstResponder(passwordField)
        
        // Start Matrix animation
        matrixView.startAnimation()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        matrixView.stopAnimation()
    }

    private func setupMatrixBackground() {
        matrixView = LockScreenView(frame: self.view.bounds)
        matrixView.autoresizingMask = [.width, .height]
        view.addSubview(matrixView)
    }
    
    private func setupUnlockInterface() {
        // Create a container with a visual effect view for the frosted glass look
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 150))
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let blurView = NSVisualEffectView(frame: container.bounds)
        blurView.blendingMode = .behindWindow
        blurView.material = .dark
        blurView.state = .active
        blurView.autoresizingMask = [.width, .height]
        container.addSubview(blurView)
        
        // Message Label
        messageLabel = NSTextField(labelWithString: "Enter Password to Unlock")
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.alignment = .center
        messageLabel.textColor = .white
        container.addSubview(messageLabel)
        
        // Password Field
        passwordField = NSSecureTextField(frame: .zero)
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.placeholderString = "Password"
        passwordField.target = self
        passwordField.action = #selector(passwordEntered)
        container.addSubview(passwordField)
        
        // Unlock Button
        unlockButton = NSButton(title: "Unlock", target: self, action: #selector(unlockButtonClicked))
        unlockButton.translatesAutoresizingMaskIntoConstraints = false
        unlockButton.bezelStyle = .rounded
        container.addSubview(unlockButton)
        
        // Add container to view
        view.addSubview(container)
        
        // Layout constraints
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
    }
    
    @objc private func passwordEntered() {
        checkPassword()
    }

    @objc private func unlockButtonClicked() {
        checkPassword()
    }
    
    private func checkPassword() {
        let password = passwordField.stringValue
        let result = UserSettings.shared.attemptLogin(password: password)
        
        switch result {
        case .success:
            SoundManager.shared.play(effect: .unlock)
            delegate?.didUnlockScreen()
            
        case .failed(let attemptsRemaining):
            SoundManager.shared.play(effect: .failedAttempt)
            shakeWindow()
            messageLabel.textColor = .systemRed
            messageLabel.stringValue = "Incorrect password. \(attemptsRemaining) attempts remaining."
            passwordField.stringValue = ""
            
        case .lockedOut(let timeRemaining):
            SoundManager.shared.play(effect: .failedAttempt)
            shakeWindow()
            messageLabel.textColor = .systemRed
            updateLockoutMessage(timeRemaining: timeRemaining)
            passwordField.isEnabled = false
            unlockButton.isEnabled = false
            startLockoutTimer()
        }
    }
    
    private func updateLockoutMessage(timeRemaining: TimeInterval) {
        let formattedTime = UserSettings.shared.formatTimeRemaining(timeRemaining)
        messageLabel.stringValue = "Too many failed attempts. Try again in \(formattedTime)."
    }
    
    private func startLockoutTimer() {
        lockoutTimer?.invalidate()
        lockoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            let remaining = UserSettings.shared.timeRemainingInLockout()
            if remaining > 0 {
                self?.updateLockoutMessage(timeRemaining: remaining)
            } else {
                timer.invalidate()
                self?.resetLockoutState()
            }
        }
    }
    
    private func resetLockoutState() {
        messageLabel.textColor = .white
        messageLabel.stringValue = "Enter Password to Unlock"
        passwordField.isEnabled = true
        unlockButton.isEnabled = true
        passwordField.stringValue = ""
        view.window?.makeFirstResponder(passwordField)
    }

    private func attemptSystemAuthentication() {
        guard UserSettings.shared.enablePasswordProtection else {
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
                        self?.delegate?.didUnlockScreen()
                    }
                }
            }
        }
    }
    
    private func shakeWindow() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        self.view.window?.contentView?.layer?.add(animation, forKey: "shake")
    }
}
