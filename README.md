# MatrixLocker

A sophisticated macOS application with Matrix-style screen lock, user activity monitoring, and comprehensive settings panel.

## Features

- **Automated Screen Locking**: Monitors user inactivity and automatically locks the screen
- **Matrix Animation**: Beautiful falling character animation during lock screen
- **Touch ID/Password Authentication**: Secure unlock using biometric authentication or system password
- **Customizable Settings**: 
  - Adjustable inactivity timeout (10-300 seconds)
  - Customizable Matrix character colors
  - Launch at login option
- **Xcode Configuration**: Built-in script for optimizing Xcode development settings
- **Modern UI**: Native macOS interface with sidebar navigation

## Project Structure

```
MatrixLocker/
├── AppDelegate.swift                 // Main application delegate
├── Main.storyboard                   // Interface Builder storyboard
├── Info.plist                        // App configuration
├── MatrixLocker.entitlements        // Security entitlements
├── Assets.xcassets/                 // App icons and assets
│
├── Controllers/
│   ├── SettingsViewController.swift      // Main settings window controller
│   ├── GeneralSettingsViewController.swift // General settings tab
│   ├── XcodeSettingsViewController.swift // Xcode configuration tab
│   ├── AboutViewController.swift         // About tab
│   └── LockScreenViewController.swift    // Lock screen management
│
├── Models/
│   └── UserSettings.swift              // User preferences storage
│
├── Views/
│   └── LockScreenView.swift            // Matrix animation rendering
│
└── Utils/
    ├── ActivityMonitor.swift           // User activity tracking
    └── LaunchAtLogin.swift             // Startup management
```

## Requirements

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.0

## Installation

1. Open `MatrixLocker.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Build and run the project (⌘+R)

## Usage

### Initial Setup

1. Launch the application
2. Configure your preferred inactivity timeout in the General settings
3. Customize the Matrix character color
4. Optionally enable "Launch at Login" for automatic startup

### Screen Locking

- The app automatically monitors user activity (mouse movement, clicks, keyboard input)
- When inactivity exceeds the configured timeout, the lock screen appears
- Authenticate using Touch ID, password, or system authentication to unlock

### Xcode Configuration

The app includes a useful script for optimizing Xcode development settings:
1. Go to the "Xcode" tab in settings
2. Copy the provided script
3. Run it in Terminal to apply developer-friendly Xcode configurations

## Security Features

- **App Sandbox**: Runs in a secure sandbox environment
- **Local Authentication**: Uses macOS LocalAuthentication framework
- **Minimal Permissions**: Only requests necessary system access
- **Secure Storage**: User preferences stored using UserDefaults

## Customization

### Timeout Settings
- Minimum: 10 seconds
- Maximum: 300 seconds (5 minutes)
- Default: 60 seconds

### Matrix Animation
- Customizable character colors
- Responsive to window resizing
- Smooth 60fps animation
- Alphanumeric character set

## Troubleshooting

### Authentication Issues
- Ensure Touch ID is configured in System Preferences
- Verify the app has necessary permissions
- Check system authentication settings

### Launch at Login Not Working
- Requires macOS 13.0 or later for modern SMAppService API
- Ensure proper entitlements are configured
- Check System Preferences > Login Items

### Performance
- The Matrix animation is optimized for smooth performance
- Minimal CPU usage when idle
- Efficient memory management with automatic cleanup

## Development

### Building
```bash
# Clone and open in Xcode
open MatrixLocker.xcodeproj

# Build from command line
xcodebuild -project MatrixLocker.xcodeproj -scheme MatrixLocker build
```

### Architecture
- **MVVM Pattern**: Clear separation of concerns
- **Delegate Pattern**: Communication between view controllers
- **Observer Pattern**: Activity monitoring and notifications
- **Singleton Pattern**: Shared user settings

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is open source. Please ensure compliance with Apple's guidelines for macOS applications.

## Credits

- Matrix-style animation inspired by the classic "Matrix" movie effect
- Built using Apple's Cocoa framework and Swift
- Activity monitoring using NSEvent global monitoring
- Authentication via LocalAuthentication framework
