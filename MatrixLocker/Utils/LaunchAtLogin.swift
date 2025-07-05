import Foundation
import ServiceManagement

// This helper uses the modern, recommended API for managing launch items.
enum LaunchAtLogin {
    private static let identifier = "\(Bundle.main.bundleIdentifier!)-Launcher"

    static var isEnabled: Bool {
        get {
            // Note: The `SMAppService` API is available from macOS 13.
            if #available(macOS 13.0, *) {
                return SMAppService.main.status == .enabled
            }
            // Fallback for older systems is more complex and not included here for simplicity.
            // For a production app, you would use the deprecated SMLoginItemSetEnabled.
            return false
        }
        set {
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        if SMAppService.main.status == .enabled {
                            try SMAppService.main.unregister()
                        }
                        try SMAppService.main.register()
                    } else {
                        try SMAppService.main.unregister()
                    }
                } catch {
                    print("Failed to update Launch at Login status: \(error.localizedDescription)")
                }
            }
        }
    }
}
