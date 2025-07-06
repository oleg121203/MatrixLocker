import Cocoa

class SettingsViewController: NSViewController {

    // MARK: - Outlets

    @IBOutlet weak var launchAtLoginCheckbox: NSButton!
    @IBOutlet weak var inactivityTimeoutTextField: NSTextField!

    // MARK: - Properties

    private let userSettings = UserSettings.shared

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Встановлюємо делегата для текстового поля
        inactivityTimeoutTextField.delegate = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        // Завантажуємо поточні налаштування та оновлюємо UI
        loadSettings()
    }

    // MARK: - Setup

    /// Завантажує налаштування та оновлює елементи інтерфейсу
    private func loadSettings() {
        // Встановлюємо стан чекбокса автозапуску
        launchAtLoginCheckbox.state = userSettings.isLaunchAtLoginEnabled ? .on : .off

        // Встановлюємо значення таймауту
        let timeout = userSettings.inactivityTimeout
        if timeout > 0 {
            inactivityTimeoutTextField.stringValue = "\(Int(timeout / 60))" // Показуємо в хвилинах
        } else {
            inactivityTimeoutTextField.stringValue = "0"
        }
    }

    // MARK: - Actions

    /// Обробник натискання на чекбокс "Запускати при вході"
    @IBAction func launchAtLoginCheckboxClicked(_ sender: NSButton) {
        let isEnabled = sender.state == .on
        userSettings.isLaunchAtLoginEnabled = isEnabled
        // Оновлюємо стан системного автозапуску
        LaunchAtLogin.isEnabled = isEnabled
    }

    /// Обробник для кнопки "Зберегти" (якщо вона є) або можна зберігати на льоту
    @IBAction func saveButtonClicked(_ sender: Any) {
        // Ця функція може бути не потрібна, якщо зберігати налаштування одразу
        view.window?.close()
    }
}

// MARK: - NSTextFieldDelegate

extension SettingsViewController: NSTextFieldDelegate {

    /// Цей метод викликається, коли редагування текстового поля завершено
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField, textField == inactivityTimeoutTextField else {
            return
        }

        // Отримуємо значення з текстового поля, конвертуємо в хвилини, а потім в секунди
        if let minutes = Int(textField.stringValue) {
            let seconds = TimeInterval(minutes * 60)
            userSettings.inactivityTimeout = seconds

            // Перезапускаємо монітор активності з новим значенням
            // Це можна зробити через сповіщення до AppDelegate
        }
    }
}
