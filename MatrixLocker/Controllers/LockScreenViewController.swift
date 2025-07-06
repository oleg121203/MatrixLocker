import Cocoa
import LocalAuthentication
import QuartzCore

protocol LockScreenDelegate: AnyObject {
    func didUnlockScreen()
}

class LockScreenViewController: NSViewController {
    weak var delegate: LockScreenDelegate?
    
    private var passwordField: NSSecureTextField!
    private var messageLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMatrixBackground()
        setupUnlockInterface()
        // Attempt biometrics as soon as the view appears
        attemptSystemAuthentication()
    }

    private func setupMatrixBackground() {
        let matrixView = LockScreenView(frame: self.view.bounds)
        matrixView.autoresizingMask = [.width, .height]
        // You can customize the lock screen matrix effect here if needed
        matrixView.rainColor = UserSettings.shared.matrixCharacterColor
        self.view.addSubview(matrixView, positioned: .below, relativeTo: nil)
        matrixView.startAnimation()
    }
    
    private func setupUnlockInterface() {
        // Create a container with a visual effect view for the frosted glass look
        let containerView = NSVisualEffectView()
        containerView.material = .hudWindow
        containerView.blendingMode = .behindWindow
        containerView.state = .active
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: "MATRIX LOCKED")
        titleLabel.font = NSFont(name: "Menlo-Bold", size: 22)
        titleLabel.textColor = .white
        titleLabel.alignment = .center

        messageLabel = NSTextField(labelWithString: "Enter password or use Touch ID")
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textColor = .lightGray
        messageLabel.alignment = .center

        passwordField = NSSecureTextField()
        passwordField.placeholderString = "Password"
        passwordField.target = self
        passwordField.action = #selector(passwordEntered)
        passwordField.font = .systemFont(ofSize: 16)
        passwordField.alignment = .center
        
        let unlockButton = NSButton(title: "Unlock", target: self, action: #selector(unlockButtonClicked))
        unlockButton.bezelStyle = .rounded

        let stackView = NSStackView(views: [titleLabel, messageLabel, passwordField, unlockButton])
        stackView.orientation = .vertical
        stackView.spacing = 15
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(stackView)
        self.view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
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
            passwordField.stringValue = ""
            messageLabel.stringValue = "Incorrect. \(attemptsRemaining) attempts remaining."
            messageLabel.textColor = .systemRed
            shakeWindow()
        case .lockedOut(let timeRemaining):
            SoundManager.shared.play(effect: .failedAttempt)
            passwordField.stringValue = ""
            passwordField.isEnabled = false
            messageLabel.stringValue = "Locked out. Try again in \(UserSettings.shared.formatTimeRemaining(timeRemaining))."
            messageLabel.textColor = .systemOrange
            startLockoutTimer()
        }
    }
    
    private func startLockoutTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if !UserSettings.shared.isLockedOut() {
                timer.invalidate()
                self.messageLabel.stringValue = "Enter password or use Touch ID"
                self.messageLabel.textColor = .lightGray
                self.passwordField.isEnabled = true
            } else {
                let remaining = UserSettings.shared.timeRemainingInLockout()
                self.messageLabel.stringValue = "Locked out. Try again in \(UserSettings.shared.formatTimeRemaining(remaining))."
            }
        }
    }

    private func attemptSystemAuthentication() {
        guard UserSettings.shared.enablePasswordProtection else {
            delegate?.didUnlockScreen()
            return
        }

        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock MatrixLocker"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        SoundManager.shared.play(effect: .unlock)
                        self?.delegate?.didUnlockScreen()
                    }
                    // If biometric fails, the user can still type their password.
                }
            }
        }
    }
    
    private func shakeWindow() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-15, 15, -10, 10, -5, 5, 0]
        self.view.window?.contentView?.layer?.add(animation, forKey: "shake")
    }
}
