import Cocoa

class ActivityMonitor {
    private enum State {
        case stopped
        case monitoring
        case readyToLock
    }

    private var state: State = .stopped
    private var activityMonitor: Any?
    private var inactivityTimer: Timer?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(startMonitoring), name: Notifications.startMonitoring, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopMonitoring), name: Notifications.stopMonitoring, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(activateNow), name: Notifications.activateNow, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopMonitoring()
    }

    @objc func startMonitoring() {
        guard state == .stopped else { return }
        print("Activity Monitor: Started")
        state = .monitoring
        resetInactivityTimer()
    }

    @objc func stopMonitoring() {
        guard state != .stopped else { return }
        print("Activity Monitor: Stopped")
        state = .stopped
        inactivityTimer?.invalidate()
        inactivityTimer = nil
        if let monitor = activityMonitor {
            NSEvent.removeMonitor(monitor)
            activityMonitor = nil
        }
    }

    @objc func activateNow() {
        print("Activity Monitor: Activating now")
        stopMonitoring() // Stop any current monitoring
        state = .monitoring
        // Start a 10-second timer, then move to readyToLock state
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.inactivityTimerDidFire()
        }
        // Important: Listen for activity during the 10-second countdown
        startListeningForActivity()
    }

    private func resetInactivityTimer() {
        inactivityTimer?.invalidate()
        let timeout = UserSettings.shared.inactivityTimeout
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.inactivityTimerDidFire()
        }
        startListeningForActivity()
    }

    private func inactivityTimerDidFire() {
        print("Activity Monitor: Inactivity timeout reached. Ready to lock.")
        state = .readyToLock
        // Stop listening for activity that resets the timer
        if let monitor = activityMonitor {
            NSEvent.removeMonitor(monitor)
            activityMonitor = nil
        }
        // Start listening for the next activity to trigger the lock
        startListeningForLockTrigger()
    }

    private func startListeningForActivity() {
        if activityMonitor != nil { return } // Already listening
        let eventMask: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown, .scrollWheel]
        activityMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] _ in
            self?.handleActivity()
        }
    }

    private func startListeningForLockTrigger() {
        if activityMonitor != nil { return } // Already listening
        let eventMask: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown, .scrollWheel]
        activityMonitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] _ in
            self?.triggerLock()
        }
    }

    private func handleActivity() {
        if state == .monitoring {
            print("Activity detected, resetting timer.")
            resetInactivityTimer()
        }
    }

    private func triggerLock() {
        if state == .readyToLock {
            print("Activity detected in ready state. Locking screen.")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notifications.userDidBecomeInactive, object: nil)
            }
            stopMonitoring()
        }
    }
}
