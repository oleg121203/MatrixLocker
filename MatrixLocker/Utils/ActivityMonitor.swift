import Foundation
import AppKit
import CoreGraphics

/// Клас для моніторингу активності користувача
class ActivityMonitor {

    private var timer: Timer?

    /// Час бездіяльності, після якого спрацьовує сповіщення
    private var inactivityTimeout: TimeInterval {
        // Переконуємось, що UserSettings доступний
        return UserSettings.shared.inactivityTimeout
    }

    init() {
        // Ініціалізація не потребує додаткових дій
    }

    /// Запускає моніторинг активності
    func startMonitoring() {
        // Зупиняємо попередній таймер, якщо він був
        stopMonitoring()

        let timeout = inactivityTimeout
        // Не запускаємо таймер, якщо таймаут вимкнено (дорівнює 0)
        guard timeout > 0 else { return }

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
        let timeout = inactivityTimeout
        guard timeout > 0 else { return }

        // ВИПРАВЛЕНО: Правильний синтаксис виклику функції для отримання часу бездіяльності
        let idleTime = CGEventSource.secondsSinceLastEventType(CGEventSourceStateID.combinedSessionState, eventType: .null)

        // Якщо час бездіяльності перевищує встановлений ліміт, надсилаємо сповіщення
        if idleTime > timeout {
            NotificationCenter.default.post(name: .userIsInactive, object: nil)
            // Зупиняємо таймер після блокування, щоб не спрацьовував повторно
            stopMonitoring()
        }
    }
}

