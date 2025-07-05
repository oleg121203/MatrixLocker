import Cocoa

class ActivityMonitor {
    private var monitor: Any?
    private var timer: Timer?
    private var lastActivityDate: Date = Date()
    private var inactivityInterval: TimeInterval = 60.0

    func startMonitoring(inactivityInterval: TimeInterval) {
        self.inactivityInterval = inactivityInterval
        let eventMask: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown, .scrollWheel]
        monitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] _ in
            self?.resetTimer()
        }
        setupTimer()
    }

    func stopMonitoring() {
        if let monitor = monitor { NSEvent.removeMonitor(monitor); self.monitor = nil }
        timer?.invalidate(); timer = nil
    }

    func update(newInterval: TimeInterval) {
        self.inactivityInterval = newInterval
        resetTimer()
    }
    
    // MARK: - New method to update settings dynamically
    func updateFromSettings() {
        let settings = UserSettings.shared
        
        // Update the inactivity interval
        let newInterval = settings.inactivityTimeout
        if newInterval != inactivityInterval {
            update(newInterval: newInterval)
            print("ActivityMonitor: Updated inactivity timeout to \(newInterval) seconds")
        }
        
        // Check if automatic lock is disabled
        if !settings.enableAutomaticLock {
            stopMonitoring()
            print("ActivityMonitor: Automatic lock disabled, stopping monitoring")
            return
        }
        
        // If monitoring was stopped and automatic lock is now enabled, restart it
        if monitor == nil && settings.enableAutomaticLock {
            startMonitoring(inactivityInterval: newInterval)
            print("ActivityMonitor: Automatic lock enabled, starting monitoring")
        }
    }

    @objc func resetTimer() {
        lastActivityDate = Date()
        timer?.invalidate()
        setupTimer()
    }

    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkInactivity), userInfo: nil, repeats: true)
    }

    @objc private func checkInactivity() {
        // Check if automatic lock is still enabled before triggering lock screen
        guard UserSettings.shared.enableAutomaticLock else {
            stopMonitoring()
            return
        }
        
        if Date().timeIntervalSince(lastActivityDate) >= inactivityInterval {
            timer?.invalidate()
            print("ActivityMonitor: User inactive for \(inactivityInterval) seconds, triggering lock screen")
            NotificationCenter.default.post(name: .userDidBecomeInactive, object: nil)
        }
    }
}
