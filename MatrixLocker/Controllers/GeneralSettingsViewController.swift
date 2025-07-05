import Cocoa

class GeneralSettingsViewController: NSViewController {

    @IBOutlet weak var timeoutLabel: NSTextField!
    @IBOutlet weak var timeoutSlider: NSSlider!
    @IBOutlet weak var characterColorWell: NSColorWell!
    @IBOutlet weak var launchAtLoginSwitch: NSSwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
    }

    private func loadSettings() {
        let settings = UserSettings.shared
        
        // Inactivity Timeout
        let timeout = settings.inactivityTimeout
        timeoutSlider.doubleValue = timeout
        timeoutLabel.stringValue = "\(Int(timeout)) seconds"
        
        // Matrix Color
        characterColorWell.color = settings.matrixCharacterColor
        
        // Launch at Login
        launchAtLoginSwitch.state = LaunchAtLogin.isEnabled ? .on : .off
    }

    @IBAction func sliderDidChange(_ sender: NSSlider) {
        let newTimeout = sender.doubleValue
        timeoutLabel.stringValue = "\(Int(newTimeout)) seconds"
        UserSettings.shared.inactivityTimeout = newTimeout
        
        // Notify the running activity monitor to update its interval
        (NSApplication.shared.delegate as? AppDelegate)?.activityMonitor.update(newInterval: newTimeout)
    }
    
    @IBAction func colorDidChange(_ sender: NSColorWell) {
        UserSettings.shared.matrixCharacterColor = sender.color
    }
    
    @IBAction func launchAtLoginDidChange(_ sender: NSSwitch) {
        LaunchAtLogin.isEnabled = (sender.state == .on)
    }
}
