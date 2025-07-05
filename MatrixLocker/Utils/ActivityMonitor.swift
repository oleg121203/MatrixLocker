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

    @objc func resetTimer() {
        lastActivityDate = Date()
        timer?.invalidate()
        setupTimer()
    }

    private func setupTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkInactivity), userInfo: nil, repeats: true)
    }

    @objc private func checkInactivity() {
        if Date().timeIntervalSince(lastActivityDate) >= inactivityInterval {
            timer?.invalidate()
            NotificationCenter.default.post(name: .userDidBecomeInactive, object: nil)
        }
    }
}
