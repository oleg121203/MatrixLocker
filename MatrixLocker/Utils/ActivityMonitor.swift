import Cocoa

class ActivityMonitor {
    private var monitor: Any?
    private var timer: Timer?
    private var sessionStartDate: Date = Date()
    private var activityTimeLimit: TimeInterval = 60.0

    func startMonitoring(inactivityInterval: TimeInterval) {
        self.activityTimeLimit = inactivityInterval
        sessionStartDate = Date()
        let eventMask: NSEvent.EventTypeMask = [.mouseMoved, .leftMouseDown, .rightMouseDown, .otherMouseDown, .keyDown, .scrollWheel]
        monitor = NSEvent.addGlobalMonitorForEvents(matching: eventMask) { [weak self] _ in
            self?.onUserActivity()
        }
        setupTimer()
    }

    func stopMonitoring() {
        if let monitor = monitor { NSEvent.removeMonitor(monitor); self.monitor = nil }
        timer?.invalidate(); timer = nil
    }

    func update(newInterval: TimeInterval) {
        self.activityTimeLimit = newInterval
        sessionStartDate = Date() // Reset session when settings change
        setupTimer()
    }
    
    // MARK: - New method to update settings dynamically
    func updateFromSettings() {
        let settings = UserSettings.shared
        
        // Update the activity time limit
        let newInterval = settings.inactivityTimeout
        if newInterval != activityTimeLimit {
            update(newInterval: newInterval)
            print("ActivityMonitor: Updated activity time limit to \(newInterval) seconds")
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
        sessionStartDate = Date()
        setupTimer()
    }
    
    private func onUserActivity() {
        // Just continue monitoring - we track total session time, not reset it
        // The timer will check if session exceeded the limit
    }

    private func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkActivityTime), userInfo: nil, repeats: true)
    }

    @objc private func checkActivityTime() {
        // Check if automatic lock is still enabled before triggering lock screen
        guard UserSettings.shared.enableAutomaticLock else {
            stopMonitoring()
            return
        }
        
        let sessionDuration = Date().timeIntervalSince(sessionStartDate)
        if sessionDuration >= activityTimeLimit {
            timer?.invalidate()
            print("ActivityMonitor: User has been active for \(activityTimeLimit) seconds, triggering lock screen")
            NotificationCenter.default.post(name: .userDidBecomeInactive, object: nil)
        }
    }
}
