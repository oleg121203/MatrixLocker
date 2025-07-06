#!/usr/bin/env swift

import Cocoa

class SimpleApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🚀 Simple app starting...")
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "grid", accessibilityDescription: "Test")
            button.action = #selector(statusItemClicked)
            button.target = self
            print("✅ Status item created")
        } else {
            print("❌ Failed to create status item")
        }
    }
    
    @objc func statusItemClicked() {
        print("Status item clicked!")
        let alert = NSAlert()
        alert.messageText = "MatrixLocker Test"
        alert.informativeText = "Status bar icon is working!"
        alert.runModal()
    }
}

let app = NSApplication.shared
let delegate = SimpleApp()
app.delegate = delegate
app.run()
