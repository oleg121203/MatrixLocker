# Main.storyboard Structure

## Scene: Settings Window

### Window Controller Scene
- **Identifier**: "Settings"
- **Class**: NSWindowController
- **Window**:
  - Title: "MatrixLocker Settings"
  - Style Mask: [titled, closable, miniaturizable]
  - Content View Controller: SettingsViewController

### Settings View Controller
- **Identifier**: "SettingsViewController"
- **Class**: SettingsViewController
- **Title**: Settings

### Tab View Structure
A NSTabView with three tabs:

#### 1. General Tab
- **Title**: "General"
- **Controls**:
  - NSSwitch (launchAtLoginSwitch)
    - Label: "Launch at Login"
    - Action: settingDidChange:
  - NSSwitch (hideFromDockSwitch)
    - Label: "Hide from Dock"
    - Action: settingDidChange:
  - NSSwitch (startMinimizedSwitch)
    - Label: "Start Minimized"
    - Action: settingDidChange:

#### 2. Matrix Tab
- **Title**: "Matrix"
- **Controls**:
  - NSColorWell (characterColorWell)
    - Label: "Character Color"
    - Action: settingDidChange:
  - NSSlider (animationSpeedSlider)
    - Min: 0.1, Max: 2.0
    - Label: "Animation Speed"
    - Action: settingDidChange:
  - NSTextField (animationSpeedLabel)
    - Alignment: Right
  - NSSlider (densitySlider)
    - Min: 0.1, Max: 1.0
    - Label: "Character Density"
    - Action: settingDidChange:
  - NSTextField (densityLabel)
    - Alignment: Right
  - NSSwitch (soundEffectsSwitch)
    - Label: "Enable Sound Effects"
    - Action: settingDidChange:
  - **Control Buttons Section**:
    - NSButton (lockScreenNowButton)
      - Title: "🔒 Lock Screen Now"
      - Action: lockScreenNowClicked:
    - NSButton (testMatrixButton)
      - Title: "🧪 Test Matrix Screensaver"
      - Action: testMatrixClicked:
    - NSButton (startStopButton)
      - Title: "▶️ Start Monitoring" / "⏸️ Stop Monitoring"
      - Action: startStopClicked:

#### 3. Security Tab
- **Title**: "Security"
- **Controls**:
  - NSSwitch (automaticLockSwitch)
    - Label: "Enable Automatic Lock"
    - Action: settingDidChange:
  - NSSlider (timeoutSlider)
    - Min: 10, Max: 300
    - Label: "Inactivity Timeout"
    - Action: settingDidChange:
  - NSTextField (timeoutLabel)
    - Alignment: Right
  - NSSwitch (passwordProtectionSwitch)
    - Label: "Enable Password Protection"
    - Action: settingDidChange:
  - NSSecureTextField (passwordField)
    - Placeholder: "New Password"
  - NSButton (setPasswordButton)
    - Title: "Set Password"
    - Action: setPasswordClicked:
  - NSStepper (maxAttemptsStepper)
    - Min: 3, Max: 10
    - Label: "Maximum Failed Attempts"
    - Action: settingDidChange:
  - NSTextField (maxAttemptsLabel)
    - Alignment: Right
  - NSSlider (lockoutDurationSlider)
    - Min: 60, Max: 3600
    - Label: "Lockout Duration"
    - Action: settingDidChange:
  - NSTextField (lockoutDurationLabel)
    - Alignment: Right

## Scene: Lock Screen

### Window Controller Scene
- **Identifier**: "LockScreen"
- **Class**: NSWindowController
- **Window**:
  - Style: Borderless
  - Level: Screen Saver
  - Content View Controller: LockScreenViewController

### Lock Screen View Controller
- **Identifier**: "LockScreenViewController"
- **Class**: LockScreenViewController

### Layout
- Main View
  - LockScreenView (background)
    - Covers entire window
  - Visual Effect View (container)
    - Material: Dark
    - Blending: Behind Window
    - Corner Radius: 12
    - Centered in window
    - Contains:
      - Title Label ("MATRIX LOCKED")
      - Message Label (messageLabel)
      - Password Field (passwordField)
      - Unlock Button
        - Action: unlockButtonClicked:

## Connections

### Settings View Controller Outlets
```swift
@IBOutlet weak var launchAtLoginSwitch: NSSwitch!
@IBOutlet weak var hideFromDockSwitch: NSSwitch!
@IBOutlet weak var startMinimizedSwitch: NSSwitch!
@IBOutlet weak var characterColorWell: NSColorWell!
@IBOutlet weak var animationSpeedSlider: NSSlider!
@IBOutlet weak var animationSpeedLabel: NSTextField!
@IBOutlet weak var densitySlider: NSSlider!
@IBOutlet weak var densityLabel: NSTextField!
@IBOutlet weak var soundEffectsSwitch: NSSwitch!
@IBOutlet weak var automaticLockSwitch: NSSwitch!
@IBOutlet weak var timeoutSlider: NSSlider!
@IBOutlet weak var timeoutLabel: NSTextField!
@IBOutlet weak var passwordProtectionSwitch: NSSwitch!
@IBOutlet weak var passwordField: NSSecureTextField!
@IBOutlet weak var setPasswordButton: NSButton!
@IBOutlet weak var maxAttemptsStepper: NSStepper!
@IBOutlet weak var maxAttemptsLabel: NSTextField!
@IBOutlet weak var lockoutDurationSlider: NSSlider!
@IBOutlet weak var lockoutDurationLabel: NSTextField!
@IBOutlet weak var lockScreenNowButton: NSButton!
@IBOutlet weak var testMatrixButton: NSButton!
@IBOutlet weak var startStopButton: NSButton!
```

### Lock Screen View Controller Outlets
```swift
@IBOutlet private weak var passwordField: NSSecureTextField!
@IBOutlet private weak var messageLabel: NSTextField!
@IBOutlet private weak var unlockButton: NSButton!
```

## Constraints

### Settings Window
- Width: 480
- Height: 320
- All controls should have standard spacing (8 points)
- Tab view should fill the window with standard margins

### Lock Screen Window
- Fills entire screen
- Container view centered with width: 300, height: auto
- Stack view inside container has 15 points spacing between elements

## Notes for Implementation
1. Make sure to set the window controller identifiers correctly in the storyboard
2. All UI elements should be properly constrained using Auto Layout
3. Connect all outlets and actions before running
4. Test tab view navigation and control states
5. Verify that the lock screen appears above all other windows
6. Ensure the settings window maintains proper size when switching tabs
