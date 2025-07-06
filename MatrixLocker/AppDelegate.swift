import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Properties

    // Статус-бар елемент для доступу до меню програми
    private var statusItem: NSStatusItem!
    // Менеджер вікон блокування, по одному на кожен екран
    private var lockWindows: [NSWindow] = []
    // Монітор активності користувача для автоматичного блокування
    private let activityMonitor = ActivityMonitor()
    // Прапорець, що показує, чи екран зараз заблоковано
    private var isLocked = false

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Налаштування статус-бар меню
        setupStatusItem()

        // Налаштування спостерігачів за подіями
        setupObservers()

        // Запуск моніторингу бездіяльності, якщо ввімкнено в налаштуваннях
        if UserSettings.shared.inactivityTimeout > 0 {
            activityMonitor.startMonitoring()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Зупиняємо моніторинг при виході з програми
        activityMonitor.stopMonitoring()
    }

    // MARK: - Setup Methods

    /// Налаштовує меню в статус-барі
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "lock.shield", accessibilityDescription: "MatrixLocker")
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Заблокувати", action: #selector(lockScreen), keyEquivalent: "l")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Налаштування", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(withTitle: "Вийти", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }

    /// Налаштовує спостерігачі за сповіщеннями
    private func setupObservers() {
        // Спостерігач для автоматичного блокування при бездіяльності
        NotificationCenter.default.addObserver(self, selector: #selector(lockScreen), name: .userIsInactive, object: nil)

        // Спостерігач для ручного блокування через меню
        NotificationCenter.default.addObserver(self, selector: #selector(lockScreen), name: .lockScreen, object: nil)

        // Спостерігач для розблокування екрану
        NotificationCenter.default.addObserver(self, selector: #selector(unlockScreen), name: .didUnlock, object: nil)
    }

    // MARK: - Actions

    /// Блокує екран, створюючи вікна на всіх моніторах
    @objc func lockScreen() {
        // Перевіряємо, чи екран вже не заблоковано
        guard !isLocked else { return }
        isLocked = true

        // Створюємо вікно блокування для кожного екрану
        for screen in NSScreen.screens {
            let lockScreenController = LockScreenViewController()

            // Створюємо вікно без рамок, яке покриває весь екран
            let window = NSWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false,
                screen: screen
            )

            // Встановлюємо рівень вікна, щоб воно було поверх усього
            window.level = .screenSaver
            window.contentViewController = lockScreenController
            window.makeKeyAndOrderFront(nil) // Показуємо вікно

            lockWindows.append(window)
        }
    }

    /// Розблоковує екран, закриваючи всі вікна блокування
    @objc func unlockScreen() {
        // Закриваємо та видаляємо всі вікна блокування
        lockWindows.forEach { $0.close() }
        lockWindows.removeAll()
        isLocked = false
    }

    /// Відкриває вікно налаштувань
    @objc func openSettings() {
        // Реалізація для відкриття вікна налаштувань.
        // Зазвичай це робиться через Storyboard або створенням нового вікна програмно.
        let settingsStoryboard = NSStoryboard(name: "Main", bundle: nil)
        guard let settingsWindowController = settingsStoryboard.instantiateController(withIdentifier: "SettingsWindowController") as? NSWindowController else {
            return
        }
        settingsWindowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
}
