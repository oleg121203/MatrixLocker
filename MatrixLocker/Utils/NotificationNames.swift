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
