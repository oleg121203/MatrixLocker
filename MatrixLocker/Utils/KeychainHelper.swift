import Foundation
import Security

/// A helper class for securely storing and retrieving data from the system Keychain.
/// This is used to manage the user's lock password, avoiding insecure storage like UserDefaults.
final class KeychainHelper {
    static let shared = KeychainHelper()
    private let service = "com.yourcompany.MatrixLocker" // IMPORTANT: Use your app's bundle identifier

    private init() {}

    /// Saves a string value to the Keychain for a specific account.
    ///
    /// - Parameters:
    ///   - value: The string to save.
    ///   - account: The account key to associate with the value.
    /// - Returns: `true` if saving was successful, `false` otherwise.
    func save(_ value: String, for account: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        // Delete any existing item before saving a new one
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieves a string value from the Keychain for a specific account.
    ///
    /// - Parameter account: The account key for the value to retrieve.
    /// - Returns: The stored string, or `nil` if it's not found or an error occurs.
    func get(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            guard let data = dataTypeRef as? Data else { return nil }
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    /// Deletes a value from the Keychain for a specific account.
    ///
    /// - Parameter account: The account key for the value to delete.
    /// - Returns: `true` if deletion was successful, `false` otherwise.
    func delete(for account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
