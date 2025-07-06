// MatrixLocker.swift
// MatrixLocker - macOS screen protector with matrix effect and strong password support

import Cocoa
import LocalAuthentication

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var lockWindowController: LockWindowController!
    var inactivityTimer: Timer?
    let inactivityTimeout: TimeInterval = 300 // 5 minutes default
    let maxFailedAttempts = 5
    var failedAttempts = 0
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupStatusItem()
        setupLockWindow()
        setupInactivityTimer()
    }
    
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "lock.shield", accessibilityDescription: "Lock Screen")
            button.action = #selector(statusItemClicked)
        }
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: NSLocalizedString("Lock Screen", comment: "Lock screen menu item"), action: #selector(lockScreen), keyEquivalent: "l"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("Quit", comment: "Quit menu item"), action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func statusItemClicked() {
        // Intentionally left empty for menu
    }
    
    @objc func lockScreen() {
        lockWindowController.showWindow(nil)
        lockWindowController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        resetFailedAttempts()
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
    
    func setupLockWindow() {
        lockWindowController = LockWindowController(windowNibName: "LockWindowController")
        lockWindowController.delegate = self
    }
    
    func setupInactivityTimer() {
        inactivityTimer = Timer.scheduledTimer(timeInterval: inactivityTimeout, target: self, selector: #selector(inactivityTimeoutReached), userInfo: nil, repeats: true)
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .mouseMoved]) { [weak self] _ in
            self?.resetInactivityTimer()
        }
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .mouseMoved]) { [weak self] event in
            self?.resetInactivityTimer()
            return event
        }
    }
    
    @objc func inactivityTimeoutReached() {
        lockScreen()
    }
    
    func resetInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(timeInterval: inactivityTimeout, target: self, selector: #selector(inactivityTimeoutReached), userInfo: nil, repeats: false)
    }
    
    func incrementFailedAttempts() {
        failedAttempts += 1
        if failedAttempts >= maxFailedAttempts {
            lockWindowController.lockOut()
        }
    }
    
    func resetFailedAttempts() {
        failedAttempts = 0
    }
}

extension AppDelegate: LockWindowControllerDelegate {
    func didEnterPassword(_ password: String) {
        if authenticate(password: password) {
            lockWindowController.close()
            resetFailedAttempts()
        } else {
            incrementFailedAttempts()
            lockWindowController.clearPasswordField()
        }
    }
    
    func authenticate(password: String) -> Bool {
        guard let storedPassword = KeychainHelper.shared.getPassword() else { return false }
        return password == storedPassword
    }
}

// MARK: - LockWindowControllerDelegate Protocol

protocol LockWindowControllerDelegate: AnyObject {
    func didEnterPassword(_ password: String)
}

// MARK: - LockWindowController

class LockWindowController: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var messageLabel: NSTextField!
    
    weak var delegate: LockWindowControllerDelegate?
    
    private var lockoutTimer: Timer?
    private var lockoutDuration: TimeInterval = 30 // seconds
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.level = .mainMenu + 1
        window?.makeKeyAndOrderFront(nil)
        window?.isOpaque = false
        window?.backgroundColor = .black
        window?.delegate = self
        passwordField.stringValue = ""
        messageLabel.stringValue = NSLocalizedString("Enter Password", comment: "Prompt to enter password")
        setupMatrixEffect()
    }
    
    func setupMatrixEffect() {
        // Add matrix effect visual here (e.g., CAEmitterLayer or custom animation)
        // TODO: Implement matrix animation
    }
    
    @IBAction func unlockButtonPressed(_ sender: Any) {
        let password = passwordField.stringValue
        delegate?.didEnterPassword(password)
    }
    
    func clearPasswordField() {
        passwordField.stringValue = ""
        messageLabel.stringValue = NSLocalizedString("Incorrect Password. Try again.", comment: "Incorrect password message")
    }
    
    func lockOut() {
        messageLabel.stringValue = NSLocalizedString("Too many attempts. Locked out.", comment: "Lockout message")
        passwordField.isEnabled = false
        lockoutTimer = Timer.scheduledTimer(withTimeInterval: lockoutDuration, repeats: false) { [weak self] _ in
            self?.passwordField.isEnabled = true
            self?.messageLabel.stringValue = NSLocalizedString("Enter Password", comment: "Prompt to enter password")
            self?.clearPasswordField()
        }
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return false
    }
}
 
// MARK: - Keychain Helper

class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    func getPassword() -> String? {
        let service = "com.example.MatrixLocker"
        let account = "userPassword"
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account,
                                    kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data, let password = String(data: data, encoding: .utf8) {
            return password
        }
        return nil
    }
    
    func savePassword(_ password: String) -> Bool {
        let service = "com.example.MatrixLocker"
        let account = "userPassword"
        let data = password.data(using: .utf8)!
        
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            let attributesToUpdate = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            return updateStatus == errSecSuccess
        } else {
            query[kSecValueData as String] = data
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            return addStatus == errSecSuccess
        }
    }
}
