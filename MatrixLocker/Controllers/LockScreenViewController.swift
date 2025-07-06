import Cocoa
import AVFoundation

class LockScreenViewController: NSViewController {

    // MARK: - State

    /// Можливі стани екрану: встановлення пароля або блокування
    private enum LockState {
        case settingPassword
        case locked
    }

    private var currentState: LockState = .locked

    // MARK: - Properties

    private let keychain = KeychainHelper.shared
    private let soundManager = SoundManager.shared

    private var passwordToConfirm: String?

    // MARK: - UI Elements

    private lazy var passwordField: NSSecureTextField = {
        let textField = NSSecureTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.alignment = .center
        textField.font = .systemFont(ofSize: 20)
        textField.target = self
        textField.action = #selector(enterButtonPressed)
        return textField
    }()

    private lazy var infoLabel: NSTextField = {
        let label = NSTextField(labelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()

    // MARK: - Lifecycle

    override func loadView() {
        // Створюємо кастомний View з ефектом матриці
        self.view = LockScreenView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkInitialState()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Встановлюємо фокус на поле вводу пароля
        passwordField.becomeFirstResponder()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(passwordField)
        view.addSubview(infoLabel)

        NSLayoutConstraint.activate([
            passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            passwordField.widthAnchor.constraint(equalToConstant: 200),

            infoLabel.bottomAnchor.constraint(equalTo: passwordField.topAnchor, constant: -20),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    /// Перевіряє, чи встановлено пароль, і налаштовує стан екрану
    private func checkInitialState() {
        if keychain.getPassword() == nil {
            // Пароль не встановлено
            currentState = .settingPassword
            infoLabel.stringValue = "Встановіть новий пароль"
        } else {
            // Пароль вже є, екран заблоковано
            currentState = .locked
            infoLabel.stringValue = "Введіть пароль для розблокування"
        }
    }

    // MARK: - Actions

    @objc private func enterButtonPressed() {
        let enteredPassword = passwordField.stringValue
        guard !enteredPassword.isEmpty else { return }

        switch currentState {
        case .settingPassword:
            handleSetPassword(password: enteredPassword)
        case .locked:
            handleUnlock(password: enteredPassword)
        }
    }

    /// Обробляє логіку встановлення нового пароля
    private func handleSetPassword(password: String) {
        if passwordToConfirm == nil {
            // Перше введення пароля
            passwordToConfirm = password
            infoLabel.stringValue = "Повторіть пароль для підтвердження"
            passwordField.stringValue = ""
        } else {
            // Друге введення (підтвердження)
            if password == passwordToConfirm {
                // Паролі співпадають, зберігаємо
                if keychain.savePassword(password: password) {
                    infoLabel.stringValue = "Пароль успішно встановлено!"
                    soundManager.playSound(named: "correct")
                    // Розблоковуємо екран після успішного встановлення
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        NotificationCenter.default.post(name: .didUnlock, object: nil)
                    }
                } else {
                    // Помилка збереження
                    infoLabel.stringValue = "Помилка збереження пароля. Спробуйте ще."
                    soundManager.playSound(named: "incorrect")
                    passwordToConfirm = nil // Скидаємо для повторної спроби
                }
            } else {
                // Паролі не співпадають
                infoLabel.stringValue = "Паролі не співпадають. Спробуйте ще."
                soundManager.playSound(named: "incorrect")
                passwordField.stringValue = ""
                passwordToConfirm = nil // Скидаємо для повторної спроби
            }
        }
    }

    /// Обробляє логіку розблокування
    private func handleUnlock(password: String) {
        guard let savedPassword = keychain.getPassword() else {
            infoLabel.stringValue = "Помилка: пароль не знайдено. Перезапустіть програму."
            soundManager.playSound(named: "incorrect")
            return
        }

        if password == savedPassword {
            // Пароль правильний
            soundManager.playSound(named: "correct")
            NotificationCenter.default.post(name: .didUnlock, object: nil)
        } else {
            // Пароль неправильний
            infoLabel.stringValue = "Неправильний пароль. Спробуйте ще."
            soundManager.playSound(named: "incorrect")
            passwordField.stringValue = ""
            // Додамо анімацію тремтіння для візуального фідбеку
            view.shake()
        }
    }
}

// Розширення для анімації тремтіння
extension NSView {
    func shake(duration: TimeInterval = 0.5) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = duration
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.0, 2.0, 0.0]
        layer?.add(animation, forKey: "shake")
    }
}
