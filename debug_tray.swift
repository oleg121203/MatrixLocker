#!/usr/bin/env swift

import Foundation
import AppKit

// List all menu bar items
if let statusBar = NSStatusBar.system.statusItem(withLength: 0) {
    print("Status bar available")
}

// Check for existing status items
let app = NSApplication.shared
print("App name: \(app.localizedName ?? "Unknown")")

// Force menu bar refresh
NSStatusBar.system.removeStatusItem(NSStatusBar.system.statusItem(withLength: 0))
