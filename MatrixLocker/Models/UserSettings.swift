import Cocoa

class UserSettings {
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard

    // Keys for UserDefaults to prevent typos
    private struct Keys {
        static let inactivityTimeout = "inactivityTimeout"
        static let matrixCharacterColor = "matrixCharacterColor"
        static let lockPassword = "lockPassword"
        static let maxFailedAttempts = "maxFailedAttempts"
        static let lockoutDuration = "lockoutDuration"
        static let enablePasswordProtection = "enablePasswordProtection"
        static let enableAutomaticLock = "enableAutomaticLock"
        static let requirePasswordOnWake = "requirePasswordOnWake"
    }

    private init() {
        // Register default values to ensure the app has a valid state on first launch
        defaults.register(defaults: [
            Keys.inactivityTimeout: 60.0, // Default: 1 minute
            Keys.matrixCharacterColor: try! NSKeyedArchiver.archivedData(withRootObject: NSColor.systemGreen, requiringSecureCoding: false),
            Keys.maxFailedAttempts: 3, // Default: 3 attempts
            Keys.lockoutDuration: 300.0, // Default: 5 minutes lockout
            Keys.enablePasswordProtection: true, // Default: password protection enabled
            Keys.enableAutomaticLock: true, // Default: automatic lock enabled
            Keys.requirePasswordOnWake: true // Default: require password on wake
        ])
    }

    // MARK: - Inactivity Timeout
    var inactivityTimeout: TimeInterval {
        get {
            return defaults.double(forKey: Keys.inactivityTimeout)
        }
        set {
            defaults.set(newValue, forKey: Keys.inactivityTimeout)
        }
    }

    // MARK: - Matrix Color
    var matrixCharacterColor: NSColor {
        get {
            guard let data = defaults.data(forKey: Keys.matrixCharacterColor),
                  let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
                return .systemGreen // Fallback to default color
            }
            return color
        }
        set {
            // We must archive NSColor to save it in UserDefaults
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) else { return }
            defaults.set(data, forKey: Keys.matrixCharacterColor)
        }
    }
    
    // MARK: - Security Settings
    var lockPassword: String? {
        get {
            return defaults.string(forKey: Keys.lockPassword)
        }
        set {
            defaults.set(newValue, forKey: Keys.lockPassword)
        }
    }
    
    var maxFailedAttempts: Int {
        get {
            return defaults.integer(forKey: Keys.maxFailedAttempts)
        }
        set {
            defaults.set(newValue, forKey: Keys.maxFailedAttempts)
        }
    }
    
    var lockoutDuration: TimeInterval {
        get {
            return defaults.double(forKey: Keys.lockoutDuration)
        }
        set {
            defaults.set(newValue, forKey: Keys.lockoutDuration)
        }
    }
    
    var enablePasswordProtection: Bool {
        get {
            return defaults.bool(forKey: Keys.enablePasswordProtection)
        }
        set {
            defaults.set(newValue, forKey: Keys.enablePasswordProtection)
        }
    }
    
    var enableAutomaticLock: Bool {
        get {
            return defaults.bool(forKey: Keys.enableAutomaticLock)
        }
        set {
            defaults.set(newValue, forKey: Keys.enableAutomaticLock)
        }
    }
    
    var requirePasswordOnWake: Bool {
        get {
            return defaults.bool(forKey: Keys.requirePasswordOnWake)
        }
        set {
            defaults.set(newValue, forKey: Keys.requirePasswordOnWake)
        }
    }
    
    // MARK: - Security Helper Methods
    func setPassword(_ password: String) {
        // In a real app, you would hash this password
        // For now, we'll store it as-is (NOT recommended for production)
        lockPassword = password.isEmpty ? nil : password
    }
    
    func validatePassword(_ inputPassword: String) -> Bool {
        guard enablePasswordProtection, let savedPassword = lockPassword else {
            return true // No password protection or no password set
        }
        return inputPassword == savedPassword
    }
}
