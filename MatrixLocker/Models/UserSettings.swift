import Foundation
import Security
import AppKit

// MARK: - UserSettings
final class UserSettings {
    static let shared = UserSettings()
    
    private init() {}
    
    var enableAutomaticLock: Bool {
        get {
            UserDefaults.standard.bool(forKey: "enableAutomaticLock")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "enableAutomaticLock")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    var startMinimized: Bool {
        get {
            UserDefaults.standard.bool(forKey: "startMinimized")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "startMinimized")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    var hideFromDock: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hideFromDock")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hideFromDock")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    var matrixSoundEffects: Bool {
        get {
            UserDefaults.standard.object(forKey: "matrixSoundEffects") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "matrixSoundEffects")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    var inactivityTimeout: TimeInterval {
        get {
            let timeout = UserDefaults.standard.double(forKey: "inactivityTimeout")
            return timeout > 0 ? timeout : 300 // Default to 5 minutes
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "inactivityTimeout")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    var enablePasswordProtection: Bool {
        get {
            UserDefaults.standard.object(forKey: "enablePasswordProtection") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "enablePasswordProtection")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    // MARK: - Login and Security
    
    enum LoginResult {
        case success
        case failed(attemptsRemaining: Int)
        case lockedOut(timeRemaining: TimeInterval)
    }
    
    private var failedAttempts: Int {
        get {
            UserDefaults.standard.integer(forKey: "failedAttempts")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "failedAttempts")
        }
    }
    
    private var lockoutStartTime: Date? {
        get {
            UserDefaults.standard.object(forKey: "lockoutStartTime") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lockoutStartTime")
        }
    }
    
    func attemptLogin(password: String) -> LoginResult {
        // Check if currently locked out
        if let timeRemaining = timeRemainingInLockout(), timeRemaining > 0 {
            return .lockedOut(timeRemaining: timeRemaining)
        }
        
        // For demo purposes, use a simple password check
        // In a real app, this should use secure password storage
        let storedPassword = UserDefaults.standard.string(forKey: "userPassword") ?? "password"
        
        if password == storedPassword {
            // Reset failed attempts on successful login
            failedAttempts = 0
            lockoutStartTime = nil
            return .success
        } else {
            failedAttempts += 1
            
            if failedAttempts >= maxFailedAttempts {
                // Start lockout
                lockoutStartTime = Date()
                return .lockedOut(timeRemaining: lockoutDuration)
            } else {
                let attemptsRemaining = maxFailedAttempts - failedAttempts
                return .failed(attemptsRemaining: attemptsRemaining)
            }
        }
    }
    
    func timeRemainingInLockout() -> TimeInterval? {
        guard let startTime = lockoutStartTime else { return nil }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = lockoutDuration - elapsed
        
        return remaining > 0 ? remaining : nil
    }
    
    func formatTimeRemaining(_ timeRemaining: TimeInterval) -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    // Matrix settings
    var matrixCharacterColor: NSColor {
        get {
            if let colorData = UserDefaults.standard.data(forKey: "matrixCharacterColor"),
               let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? NSColor {
                return color
            }
            return NSColor.green
        }
        set {
            let colorData = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
            UserDefaults.standard.set(colorData, forKey: "matrixCharacterColor")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    var matrixAnimationSpeed: Double {
        get {
            let speed = UserDefaults.standard.double(forKey: "matrixAnimationSpeed")
            return speed > 0 ? speed : 1.0 // Default speed 1.0x
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "matrixAnimationSpeed")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    var matrixDensity: Double {
        get {
            let density = UserDefaults.standard.double(forKey: "matrixDensity")
            return density > 0 ? density : 0.5 // Default to 50%
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "matrixDensity")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    // Lockout and security settings
    var maxFailedAttempts: Int {
        get { UserDefaults.standard.integer(forKey: "maxFailedAttempts") > 0 ? UserDefaults.standard.integer(forKey: "maxFailedAttempts") : 5 }
        set {
            UserDefaults.standard.set(newValue, forKey: "maxFailedAttempts")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    var lockoutDuration: TimeInterval {
        get {
            let duration = UserDefaults.standard.double(forKey: "lockoutDuration")
            return duration > 0 ? duration : 300 // Default to 5 minutes
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lockoutDuration")
            NotificationCenter.default.post(name: Notifications.settingsDidChange, object: nil)
        }
    }
    
    // Password management using PasswordManager
    var lockPassword: String? {
        let manager = PasswordManager()
        return manager.readPassword()
    }
    
    func setPassword(_ password: String?) {
        let manager = PasswordManager()
        if let password = password, !password.isEmpty {
            manager.savePassword(password)
        } else {
            manager.deletePassword()
        }
    }
}

// MARK: - KeychainHelper
final class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}

    func save(_ data: Data, service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account,
            kSecValueData as String   : data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func read(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// Example usage with comments about using KeychainHelper.shared

class PasswordManager {
    private let service = "com.example.myapp"
    private let account = "userPassword"

    // Save password to Keychain using KeychainHelper.shared
    func savePassword(_ password: String) {
        if let data = password.data(using: .utf8) {
            KeychainHelper.shared.save(data, service: service, account: account)
        }
    }

    // Read password from Keychain using KeychainHelper.shared
    func readPassword() -> String? {
        guard let data = KeychainHelper.shared.read(service: service, account: account) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    // Delete password from Keychain using KeychainHelper.shared
    func deletePassword() {
        KeychainHelper.shared.delete(service: service, account: account)
    }
}

