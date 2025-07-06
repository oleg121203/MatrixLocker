import Foundation

class UserSettings {
    static let shared = UserSettings()
    private init() {}

    private let inactivityTimeoutKey = "inactivityTimeoutKey"
    private let launchAtLoginKey = "launchAtLoginKey"
    private let defaults = UserDefaults.standard

    var inactivityTimeout: TimeInterval {
        get {
            let value = defaults.double(forKey: inactivityTimeoutKey)
            return value > 0 ? value : 300 // Default 5 minutes
        }
        set {
            defaults.set(newValue, forKey: inactivityTimeoutKey)
        }
    }

    var isLaunchAtLoginEnabled: Bool {
        get { defaults.bool(forKey: launchAtLoginKey) }
        set { defaults.set(newValue, forKey: launchAtLoginKey) }
    }
}
