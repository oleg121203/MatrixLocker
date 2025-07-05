# MatrixLocker Setup Guide

## Quick Start

### Option 1: Build Script (Recommended)
```bash
cd /Users/dev/Documents/NIMDA/MATRIX
./build.sh
```

### Option 2: Xcode
1. Open `MatrixLocker.xcodeproj` in Xcode
2. Select your development team
3. Press ⌘+R to build and run

## Detailed Setup Instructions

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0 or later
- Apple Developer Account (for signing)

### Step 1: Project Configuration
1. Open the project in Xcode
2. Select the MatrixLocker target
3. In "Signing & Capabilities":
   - Select your development team
   - Verify the bundle identifier is unique
   - Ensure "App Sandbox" capability is enabled

### Step 2: Entitlements
The project includes necessary entitlements for:
- App Sandbox
- Automation (for activity monitoring)
- User-selected file access

### Step 3: Build Settings
Key build settings are pre-configured:
- Deployment Target: macOS 13.0
- Swift Language Version: 5.0
- Code Signing: Automatic

### Step 4: First Run
1. Build and run the application
2. Grant any requested permissions
3. Configure settings in the preferences window

## Troubleshooting

### Common Issues

#### Build Errors
- **"No signing certificate"**: Add your Apple Developer account in Xcode preferences
- **"Bundle identifier in use"**: Change the bundle identifier to something unique
- **"Missing entitlements"**: Ensure MatrixLocker.entitlements is properly referenced

#### Runtime Issues
- **Authentication not working**: Check Touch ID settings in System Preferences
- **Activity monitoring not working**: Grant accessibility permissions if prompted
- **Launch at login not working**: Requires macOS 13.0+ and proper entitlements

#### Performance Issues
- **High CPU usage**: Check if multiple instances are running
- **Memory leaks**: Restart the application if experiencing issues

### Permissions

The app may request the following permissions:
1. **Accessibility**: For global activity monitoring
2. **Input Monitoring**: For detecting user activity
3. **Screen Recording**: For full-screen lock overlay

Grant these permissions in System Preferences > Security & Privacy.

## Customization

### Modifying the Matrix Animation
Edit `Views/LockScreenView.swift`:
- Change character sets
- Adjust animation speed
- Modify visual effects

### Adding New Settings
1. Add properties to `Models/UserSettings.swift`
2. Create UI in the appropriate settings view controller
3. Connect outlets and actions

### Changing Default Values
Modify the defaults in `UserSettings.init()`:
```swift
defaults.register(defaults: [
    Keys.inactivityTimeout: 60.0,  // Change default timeout
    // Add other defaults
])
```

## Security Considerations

### App Sandbox
The app runs in a sandbox for security:
- Limited file system access
- Restricted network access
- Controlled system interaction

### Authentication
- Uses LocalAuthentication framework
- Supports Touch ID, Face ID, and password
- No authentication data is stored by the app

### Activity Monitoring
- Minimal data collection
- No personal information stored
- Activity data not transmitted externally

## Deployment

### For Personal Use
The Debug build is sufficient for personal use.

### For Distribution
1. Use Release configuration
2. Enable code signing with Developer ID
3. Notarize the application for macOS Gatekeeper
4. Create a disk image (.dmg) for distribution

### App Store Distribution
Additional steps required:
1. Use App Store provisioning profile
2. Enable App Store distribution in build settings
3. Follow App Store Review Guidelines
4. Submit through App Store Connect

## Advanced Configuration

### Custom Build Configurations
Create additional build configurations for:
- Beta testing
- Different feature sets
- Environment-specific settings

### Continuous Integration
Set up automated builds with:
- GitHub Actions
- Xcode Cloud
- Jenkins

### Localization
Add support for multiple languages:
1. Add localization files
2. Use NSLocalizedString for text
3. Test with different language settings

## Support

### Documentation
- Apple Developer Documentation
- Swift Programming Language Guide
- macOS Human Interface Guidelines

### Community
- Stack Overflow (swift, macos, xcode tags)
- Apple Developer Forums
- Swift.org community

### Debugging
Enable additional logging:
1. Add print statements
2. Use Xcode debugger
3. Check Console.app for system logs

## Updates and Maintenance

### Keeping Dependencies Current
- Update Xcode regularly
- Check for macOS SDK updates
- Review deprecation warnings

### Testing
- Test on different macOS versions
- Verify on various hardware configurations
- Check with different user configurations

### Monitoring
- Monitor crash reports
- Track performance metrics
- Collect user feedback

## Legal and Compliance

### Privacy
- The app collects minimal data
- No personal information transmitted
- Users control all settings

### Terms of Use
- Open source components properly attributed
- Compliance with Apple guidelines
- Respect for user privacy
