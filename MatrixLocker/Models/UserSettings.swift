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
        static let matrixAnimationSpeed = "matrixAnimationSpeed"
        static let matrixDensity = "matrixDensity"
        static let enableSoundEffects = "enableSoundEffects"
        static let matrixSoundEffects = "matrixSoundEffects"
        static let showTimeRemaining = "showTimeRemaining"
        static let enableKeyboardShortcuts = "enableKeyboardShortcuts"
        static let hideFromDock = "hideFromDock"
        static let startMinimized = "startMinimized"
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
            Keys.requirePasswordOnWake: true, // Default: require password on wake
            Keys.matrixAnimationSpeed: 1.0, // Default: normal speed
            Keys.matrixDensity: 0.7, // Default: 70% density
            Keys.enableSoundEffects: true, // Default: sound effects enabled
            Keys.matrixSoundEffects: true,
            Keys.showTimeRemaining: true, // Default: show time remaining
            Keys.enableKeyboardShortcuts: true, // Default: keyboard shortcuts enabled
            Keys.hideFromDock: false, // Default: show in dock
            Keys.startMinimized: false // Default: start normally
        ])
    }

    // MARK: - Inactivity Timeout
    var inactivityTimeout: TimeInterval {
        get {
            return defaults.double(forKey: Keys.inactivityTimeout)
        }
        set {
            // Validate range: 10 seconds to 5 minutes (300 seconds)
            let clampedValue = max(10.0, min(300.0, newValue))
            defaults.set(clampedValue, forKey: Keys.inactivityTimeout)
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
    
    // MARK: - Matrix Visual Settings
    var matrixAnimationSpeed: Double {
        get {
            return defaults.double(forKey: Keys.matrixAnimationSpeed)
        }
        set {
            defaults.set(newValue, forKey: Keys.matrixAnimationSpeed)
        }
    }
    
    var matrixDensity: Double {
        get {
            return defaults.double(forKey: Keys.matrixDensity)
        }
        set {
            defaults.set(newValue, forKey: Keys.matrixDensity)
        }
    }
    
    // MARK: - UI/UX Settings
    var matrixSoundEffects: Bool {
        get {
            return defaults.bool(forKey: Keys.enableSoundEffects)
        }
        set {
            defaults.set(newValue, forKey: Keys.enableSoundEffects)
        }
    }
    
    var showTimeRemaining: Bool {
        get {
            return defaults.bool(forKey: Keys.showTimeRemaining)
        }
        set {
            defaults.set(newValue, forKey: Keys.showTimeRemaining)
        }
    }
    
    var enableKeyboardShortcuts: Bool {
        get {
            return defaults.bool(forKey: Keys.enableKeyboardShortcuts)
        }
        set {
            defaults.set(newValue, forKey: Keys.enableKeyboardShortcuts)
        }
    }
    
    var hideFromDock: Bool {
        get {
            return defaults.bool(forKey: Keys.hideFromDock)
        }
        set {
            defaults.set(newValue, forKey: Keys.hideFromDock)
            updateDockVisibility()
        }
    }
    
    var startMinimized: Bool {
        get {
            return defaults.bool(forKey: Keys.startMinimized)
        }
        set {
            defaults.set(newValue, forKey: Keys.startMinimized)
        }
    }
    
    // MARK: - Helper Methods
    private func updateDockVisibility() {
        if hideFromDock {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }
    
    // MARK: - Security Helper Methods
    func setPassword(_ password: String) {
        // In a real app, you would hash this password
        // For now, we'll store it as-is (NOT recommended for production)
        lockPassword = password.isEmpty ? nil : password
    }
    
    func checkPassword(_ input: String) -> Bool {
        guard enablePasswordProtection, let savedPassword = lockPassword else {
            return true // Success if password protection is off
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

    func remainingAttempts() -> Int {
        return max(0, maxFailedAttempts - failedAttempts)
    }
    
    func validatePassword(_ inputPassword: String) -> Bool {
        guard enablePasswordProtection, let savedPassword = lockPassword else {
            return true // No password protection or no password set
        }
        return inputPassword == savedPassword
    }
    
    // MARK: - Failed Attempts Management
    
    private struct SecurityKeys {
        static let failedAttempts = "failedAttempts"
        static let lastFailedAttempt = "lastFailedAttempt"
        static let lockoutEndTime = "lockoutEndTime"
    }
    
    var failedAttempts: Int {
        get {
            return defaults.integer(forKey: SecurityKeys.failedAttempts)
        }
        set {
            defaults.set(newValue, forKey: SecurityKeys.failedAttempts)
        }
    }
    
    private var lastFailedAttempt: Date? {
        get {
            return defaults.object(forKey: SecurityKeys.lastFailedAttempt) as? Date
        }
        set {
            defaults.set(newValue, forKey: SecurityKeys.lastFailedAttempt)
        }
    }
    
    private var lockoutEndTime: Date? {
        get {
            return defaults.object(forKey: SecurityKeys.lockoutEndTime) as? Date
        }
        set {
            defaults.set(newValue, forKey: SecurityKeys.lockoutEndTime)
        }
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
        // Check if currently locked out
        if isLockedOut() {
            let remaining = timeRemainingInLockout()
            return .lockedOut(timeRemaining: remaining)
        }
        
        // Validate password
        if validatePassword(password) {
            // Successful login - reset failed attempts
            resetFailedAttempts()
            return .success
        } else {
            // Failed login - increment counter
            return handleFailedAttempt()
        }
    }
    
    private func handleFailedAttempt() -> LoginResult {
        failedAttempts += 1
        lastFailedAttempt = Date()
        
        if failedAttempts >= maxFailedAttempts {
            // Lock out the user
            lockoutEndTime = Date().addingTimeInterval(lockoutDuration)
            return .lockedOut(timeRemaining: lockoutDuration)
        } else {
            let remainingAttempts = maxFailedAttempts - failedAttempts
            return .failed(attemptsRemaining: remainingAttempts)
        }
    }
    
    private func resetFailedAttempts() {
        failedAttempts = 0
        lastFailedAttempt = nil
        lockoutEndTime = nil
    }
    
    // MARK: - Utility Methods
    
    func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let totalMinutes = Int(timeInterval / 60)
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        
        if totalMinutes > 0 {
            return String(format: "%d:%02d", totalMinutes, seconds)
        } else {
            return "\(seconds) seconds"
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
