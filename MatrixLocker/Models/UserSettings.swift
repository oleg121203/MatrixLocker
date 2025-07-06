import Foundation
import Security

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
