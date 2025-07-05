# MatrixLocker

A sophisticated macOS application that provides a Matrix-style screen lock, monitors user activity, and includes a comprehensive settings panel.

## Features

- **Automated Screen Locking**: Locks the screen after a configurable period of user inactivity.
- **Matrix Animation**: Displays a beautiful falling character animation on the lock screen.
- **Secure Unlock**: Uses Touch ID or the system password for authentication.
- **Customizable Settings**:
  - Adjustable inactivity timeout (10-300 seconds).
  - Customizable Matrix character colors.
  - Option to launch at login.
- **Modern UI**: A native macOS interface with sidebar navigation.

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Apple Developer Account (for code signing)

## Quick Start

The easiest way to build and run the project is to use the provided script.

1.  **Clone the repository.**
2.  **Open your terminal, navigate to the project directory, and run:**

    ```bash
    ./run.sh
    ```
    This command will build and launch the application.

## Build and Run Instructions

A single script, `run.sh`, manages all common development tasks.

```bash
# Build and run the application (default action)
./run.sh

# Only build the application
./run.sh build

# Clean the build folder and then build
./run.sh clean

# Open the project in Xcode
./run.sh xcode

# Display help information
./run.sh help
```

### Manual Build with Xcode

1.  Open `MatrixLocker.xcodeproj` in Xcode.
2.  Select your development team in the "Signing & Capabilities" tab.
3.  Press `Cmd + R` to build and run.

## Project Structure

```
MatrixLocker/
├── AppDelegate.swift                 // Main application delegate
├── Controllers/                      // View controllers for UI management
├── Models/                           // Data models (e.g., UserSettings)
├── Views/                            // Custom views (e.g., LockScreenView)
└── Utils/                            // Utility classes (e.g., ActivityMonitor)
Assets.xcassets/                      // App icons and other assets
Info.plist                            // App configuration
MatrixLocker.xcodeproj/               // Xcode project file
run.sh                                // Unified build and run script
```

## Troubleshooting

- **"No signing certificate" error in Xcode:** Ensure you have selected your Apple Developer account in Xcode's preferences and assigned it to the project in "Signing & Capabilities".
- **"Bundle identifier in use" error:** Change the bundle identifier in the project settings to a unique string.
- **Activity monitoring not working:** The app may require Accessibility permissions. Grant them in `System Settings > Privacy & Security > Accessibility`.

## Development

The application follows standard macOS development patterns, including:
- **MVVM (Model-View-ViewModel)** for separation of concerns.
- **Delegate and Observer patterns** for communication between components.
- **UserDefaults** for persisting user settings.

Contributions are welcome. Please open an issue or submit a pull request.

## License

This project is open source. Please adhere to Apple's guidelines when developing and distributing macOS applications.
