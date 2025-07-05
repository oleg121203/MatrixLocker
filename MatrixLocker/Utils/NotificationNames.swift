import Foundation

struct Notifications {
    static let startMonitoring = Notification.Name("startMonitoring")
    static let stopMonitoring = Notification.Name("stopMonitoring")
    static let activateNow = Notification.Name("activateNow")
    static let userDidBecomeInactive = Notification.Name("userDidBecomeInactive")
    static let settingsDidChange = Notification.Name("settingsDidChange")
    static let matrixPreview = Notification.Name("MatrixPreview")
}
