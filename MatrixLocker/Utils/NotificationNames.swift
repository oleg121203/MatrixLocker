import Cocoa

extension Notification.Name {
    /// Spawns when automatic monitoring should start
    static let startMonitoring = Notification.Name("startMonitoring")

    /// Spawns when automatic monitoring should stop
    static let stopMonitoring = Notification.Name("stopMonitoring")

    /// Spawns when a manual activate-now countdown is requested
    static let activateNow = Notification.Name("activateNow")

    /// Spawns when the user becomes inactive and the lock should engage
    static let userDidBecomeInactive = Notification.Name("userDidBecomeInactive")

    /// Spawns when any settings have changed
    static let settingsDidChange = Notification.Name("settingsDidChange")

    /// Spawns for manual lock screen requests
    static let lockScreen = Notification.Name("lockScreen")

    /// Spawns after a successful unlock
    static let didUnlock = Notification.Name("didUnlock")
}

/// Convenience wrapper to reference notification names via `Notifications.xxx`.
struct Notifications {
    static let startMonitoring = Notification.Name.startMonitoring
    static let stopMonitoring = Notification.Name.stopMonitoring
    static let activateNow = Notification.Name.activateNow
    static let userDidBecomeInactive = Notification.Name.userDidBecomeInactive
    static let settingsDidChange = Notification.Name.settingsDidChange
    static let lockScreen = Notification.Name.lockScreen
    static let didUnlock = Notification.Name.didUnlock
}

// MARK: - Sound Manager

/// Manages the playback of sound effects for the application.
final class SoundManager {
    static let shared = SoundManager()
    private init() {}

    enum SoundEffect {
        case lock
        case unlock
        case failedAttempt
    }

    /// Plays a specified sound effect if sound effects are enabled in user settings.
    ///
    /// - Parameter effect: The `SoundEffect` to play.
    func play(effect: SoundEffect) {
        guard UserSettings.shared.matrixSoundEffects else { return }

        let soundName: String
        switch effect {
        case .lock:
            soundName = "Tink"
        case .unlock:
            soundName = "Submarine"
        case .failedAttempt:
            soundName = "Basso"
        }

        if let sound = NSSound(named: soundName) {
            sound.play()
        }
    }
}
