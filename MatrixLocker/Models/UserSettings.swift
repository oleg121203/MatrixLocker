import Cocoa

class UserSettings {
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard

    // Keys for UserDefaults to prevent typos
    private struct Keys {
        static let inactivityTimeout = "inactivityTimeout"
        static let matrixCharacterColor = "matrixCharacterColor"
        // static let lockPassword = "lockPassword" // REMOVED FOR SECURITY
        static let maxFailedAttempts = "maxFailedAttempts"
        static let lockoutDuration = "lockoutDuration"
        static let enablePasswordProtection = "enablePasswordProtection"
        static let enableAutomaticLock = "enableAutomaticLock"
        static let requirePasswordOnWake = "requirePasswordOnWake"
        static let matrixAnimationSpeed = "matrixAnimationSpeed"
        static let matrixDensity = "matrixDensity"
        static let matrixSoundEffects = "matrixSoundEffects"
        static let showTimeRemaining = "showTimeRemaining"
        static let hideFromDock = "hideFromDock"
        static let startMinimized = "startMinimized"
        
        // Keychain account key
        static let passwordAccount = "userLockPassword"
    }

    private init() {
        // Register default values to ensure the app has a valid state on first launch
        defaults.register(defaults: [
            Keys.inactivityTimeout: 60.0,
            Keys.matrixCharacterColor: try! NSKeyedArchiver.archivedData(withRootObject: NSColor.systemGreen, requiringSecureCoding: false),
            Keys.maxFailedAttempts: 5,
            Keys.lockoutDuration: 300.0,
            Keys.enablePasswordProtection: true,
            Keys.enableAutomaticLock: true,
            Keys.requirePasswordOnWake: true,
            Keys.matrixAnimationSpeed: 1.0,
            Keys.matrixDensity: 0.7,
            Keys.matrixSoundEffects: false,
            Keys.showTimeRemaining: true,
            Keys.hideFromDock: false,
            Keys.startMinimized: false
        ])
    }

    // MARK: - Inactivity Timeout
    var inactivityTimeout: TimeInterval {
        get { return defaults.double(forKey: Keys.inactivityTimeout) }
        set {
            let clampedValue = max(10.0, min(300.0, newValue))
            defaults.set(clampedValue, forKey: Keys.inactivityTimeout)
        }
    }

    // MARK: - Matrix Color
    var matrixCharacterColor: NSColor {
        get {
            guard let data = defaults.data(forKey: Keys.matrixCharacterColor),
                  let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
                return .systemGreen
            }
            return color
        }
        set {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) else { return }
            defaults.set(data, forKey: Keys.matrixCharacterColor)
        }
    }
    
    // MARK: - Security Settings
    var lockPassword: String? {
        return KeychainHelper.shared.get(for: Keys.passwordAccount)
    }
    
    var maxFailedAttempts: Int {
        get { return defaults.integer(forKey: Keys.maxFailedAttempts) }
        set { defaults.set(newValue, forKey: Keys.maxFailedAttempts) }
    }
    
    var lockoutDuration: TimeInterval {
        get { return defaults.double(forKey: Keys.lockoutDuration) }
        set { defaults.set(newValue, forKey: Keys.lockoutDuration) }
    }
    
    var enablePasswordProtection: Bool {
        get { return defaults.bool(forKey: Keys.enablePasswordProtection) }
        set { defaults.set(newValue, forKey: Keys.enablePasswordProtection) }
    }
    
    var enableAutomaticLock: Bool {
        get { return defaults.bool(forKey: Keys.enableAutomaticLock) }
        set { defaults.set(newValue, forKey: Keys.enableAutomaticLock) }
    }
        
    // MARK: - Matrix Visual Settings
    var matrixAnimationSpeed: Double {
        get { return defaults.double(forKey: Keys.matrixAnimationSpeed) }
        set { defaults.set(newValue, forKey: Keys.matrixAnimationSpeed) }
    }
    
    var matrixDensity: Double {
        get { return defaults.double(forKey: Keys.matrixDensity) }
        set { defaults.set(newValue, forKey: Keys.matrixDensity) }
    }
    
    // MARK: - UI/UX Settings
    var matrixSoundEffects: Bool {
        get { return defaults.bool(forKey: Keys.matrixSoundEffects) }
        set { defaults.set(newValue, forKey: Keys.matrixSoundEffects) }
    }
    
    var showTimeRemaining: Bool {
        get { return defaults.bool(forKey: Keys.showTimeRemaining) }
        set { defaults.set(newValue, forKey: Keys.showTimeRemaining) }
    }
    
    var hideFromDock: Bool {
        get { return defaults.bool(forKey: Keys.hideFromDock) }
        set {
            defaults.set(newValue, forKey: Keys.hideFromDock)
            // The AppDelegate should observe this change and handle the UI update.
        }
    }
    
    var startMinimized: Bool {
        get { return defaults.bool(forKey: Keys.startMinimized) }
        set { defaults.set(newValue, forKey: Keys.startMinimized) }
    }
        
    // MARK: - Security Helper Methods
    func setPassword(_ password: String?) {
        guard let password = password, !password.isEmpty else {
            _ = KeychainHelper.shared.delete(for: Keys.passwordAccount)
            return
        }
        _ = KeychainHelper.shared.save(password, for: Keys.passwordAccount)
    }
    
    func checkPassword(_ input: String) -> Bool {
        guard enablePasswordProtection, let savedPassword = lockPassword else {
            return true // Success if password protection is off or no password is set
        }
        return input == savedPassword
    }

    func recordFailedAttempt() {
        failedAttempts += 1
        lastFailedAttempt = Date()
        
        if failedAttempts >= maxFailedAttempts {
            lockoutEndTime = Date().addingTimeInterval(lockoutDuration)
        }
    }
    
    // MARK: - Failed Attempts Management
    
    private struct SecurityKeys {
        static let failedAttempts = "failedAttempts"
        static let lastFailedAttempt = "lastFailedAttempt"
        static let lockoutEndTime = "lockoutEndTime"
    }
    
    var failedAttempts: Int {
        get { return defaults.integer(forKey: SecurityKeys.failedAttempts) }
        set { defaults.set(newValue, forKey: SecurityKeys.failedAttempts) }
    }
    
    private var lastFailedAttempt: Date? {
        get { return defaults.object(forKey: SecurityKeys.lastFailedAttempt) as? Date }
        set { defaults.set(newValue, forKey: SecurityKeys.lastFailedAttempt) }
    }
    
    private var lockoutEndTime: Date? {
        get { return defaults.object(forKey: SecurityKeys.lockoutEndTime) as? Date }
        set { defaults.set(newValue, forKey: SecurityKeys.lockoutEndTime) }
    }
    
    // MARK: - Security Check Methods
    
    func isLockedOut() -> Bool {
        guard let lockoutEnd = lockoutEndTime else { return false }
        return Date() < lockoutEnd
    }
    
    func timeRemainingInLockout() -> TimeInterval {
        guard let lockoutEnd = lockoutEndTime else { return 0 }
        let remaining = lockoutEnd.timeIntervalSince(Date())
        return max(0, remaining)
    }
    
    func attemptLogin(password: String) -> LoginResult {
        if isLockedOut() {
            let remaining = timeRemainingInLockout()
            return .lockedOut(timeRemaining: remaining)
        }
        
        if checkPassword(password) {
            resetFailedAttempts()
            return .success
        }
        
        return handleFailedAttempt()
    }
    
    private func handleFailedAttempt() -> LoginResult {
        failedAttempts += 1
        let attemptsRemaining = maxFailedAttempts - failedAttempts
        
        if attemptsRemaining <= 0 {
            lockoutEndTime = Date().addingTimeInterval(lockoutDuration)
            return .lockedOut(timeRemaining: lockoutDuration)
        }
        
        return .failed(attemptsRemaining: attemptsRemaining)
    }
    
    func resetFailedAttempts() {
        failedAttempts = 0
        lockoutEndTime = nil
    }
    
    // MARK: - Utility Methods
    func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let totalMinutes = Int(timeInterval / 60)
        let minutes = totalMinutes % 60
        let hours = totalMinutes / 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

// MARK: - Login Result Enum

enum LoginResult {
    case success
    case failed(attemptsRemaining: Int)
    case lockedOut(timeRemaining: TimeInterval)
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
    
    var errorMessage: String {
        switch self {
        case .success:
            return ""
        case .failed(let remaining):
            return "Incorrect password. \(remaining) attempt\(remaining != 1 ? "s" : "") remaining."
        case .lockedOut(let timeRemaining):
            let timeString = UserSettings.shared.formatTimeRemaining(timeRemaining)
            return "Too many failed attempts. Try again in \(timeString)."
        }
    }
}
