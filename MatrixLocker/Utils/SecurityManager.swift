import Foundation
import Cocoa

class SecurityManager {
    static let shared = SecurityManager()
    
    private let defaults = UserDefaults.standard
    private let failedAttemptsKey = "failedAttempts"
    private let lastFailedAttemptKey = "lastFailedAttempt"
    private let lockoutEndTimeKey = "lockoutEndTime"
    
    private init() {}
    
    // MARK: - Failed Attempts Management
    
    var failedAttempts: Int {
        get {
            return defaults.integer(forKey: failedAttemptsKey)
        }
        set {
            defaults.set(newValue, forKey: failedAttemptsKey)
        }
    }
    
    var lastFailedAttempt: Date? {
        get {
            return defaults.object(forKey: lastFailedAttemptKey) as? Date
        }
        set {
            defaults.set(newValue, forKey: lastFailedAttemptKey)
        }
    }
    
    var lockoutEndTime: Date? {
        get {
            return defaults.object(forKey: lockoutEndTimeKey) as? Date
        }
        set {
            defaults.set(newValue, forKey: lockoutEndTimeKey)
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
        let settings = UserSettings.shared
        if settings.validatePassword(password) {
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
        
        let settings = UserSettings.shared
        let maxAttempts = settings.maxFailedAttempts
        
        if failedAttempts >= maxAttempts {
            // Lock out the user
            let lockoutDuration = settings.lockoutDuration
            lockoutEndTime = Date().addingTimeInterval(lockoutDuration)
            return .lockedOut(timeRemaining: lockoutDuration)
        } else {
            let remainingAttempts = maxAttempts - failedAttempts
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
            let timeString = SecurityManager.shared.formatTimeRemaining(timeRemaining)
            return "Too many failed attempts. Try again in \(timeString)."
        }
    }
}
