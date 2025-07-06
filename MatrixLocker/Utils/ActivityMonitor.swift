import Foundation
import AppKit

/// Клас для моніторингу активності користувача
class ActivityMonitor {

    private var timer: Timer?
    private var lastActivityTimestamp: TimeInterval

    /// Час бездіяльності, після якого спрацьовує сповіщення
    private var inactivityTimeout: TimeInterval {
        return UserSettings.shared.inactivityTimeout
    }

    init() {
        self.lastActivityTimestamp = Date.timeIntervalSinceReferenceDate
    }

    /// Запускає моніторинг активності
    func startMonitoring() {
        // Зупиняємо попередній таймер, якщо він був
        stopMonitoring()

        // Не запускаємо таймер, якщо таймаут вимкнено
        guard inactivityTimeout > 0 else { return }

        // Створюємо та запускаємо таймер, що перевіряє активність кожні 30 секунд
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.checkActivity()
        }
    }

    /// Зупиняє моніторинг активності
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    /// Перевіряє час бездіяльності та надсилає сповіщення, якщо потрібно
    private func checkActivity() {
        // Отримуємо час з моменту останньої події (рух миші, натискання клавіші)
        let idleTime = CGEventSource.secondsSinceLastEventType(for: .combinedSessionState)

        // Якщо час бездіяльності перевищує встановлений ліміт, надсилаємо сповіщення
        if idleTime > inactivityTimeout {
            NotificationCenter.default.post(name: .userIsInactive, object: nil)
            // Можна зупинити таймер після блокування, щоб не спрацьовував повторно
            stopMonitoring()
        }
    }
}
