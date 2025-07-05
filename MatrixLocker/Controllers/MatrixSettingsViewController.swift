import Cocoa

class MatrixSettingsViewController: NSViewController {

    // Matrix Visual Effects
    @IBOutlet weak var characterColorWell: NSColorWell!
    @IBOutlet weak var animationSpeedSlider: NSSlider!
    @IBOutlet weak var animationSpeedLabel: NSTextField!
    @IBOutlet weak var densitySlider: NSSlider!
    @IBOutlet weak var densityLabel: NSTextField!
    
    // Matrix Audio & Interaction
    @IBOutlet weak var soundEffectsSwitch: NSSwitch!
    @IBOutlet weak var showTimeRemainingSwitch: NSSwitch!
    
    // Matrix Presets
    @IBOutlet weak var presetPopUpButton: NSPopUpButton!
    @IBOutlet weak var previewButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        updateUI()
        setupPresets()
    }
    
    private func updateUI() {
        // Ensure sliders are always enabled
        animationSpeedSlider?.isEnabled = true
        densitySlider?.isEnabled = true
    }
    
    private func setupUI() {
        // Set up modern styling for the Matrix settings view
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
    }
    
    private func setupPresets() {
        presetPopUpButton?.removeAllItems()
        presetPopUpButton?.addItems(withTitles: [
            "Classic Matrix",
            "Fast Rain",
            "Sparse Code",
            "Dense Storm",
            "Slow Drip",
            "Custom"
        ])
        presetPopUpButton?.selectItem(withTitle: "Custom")
    }

    private func loadSettings() {
        let settings = UserSettings.shared
        
        // Matrix Visual Effects
        characterColorWell?.color = settings.matrixCharacterColor
        
        animationSpeedSlider?.doubleValue = settings.matrixAnimationSpeed
        animationSpeedLabel?.stringValue = String(format: "%.1fx", settings.matrixAnimationSpeed)
        
        densitySlider?.doubleValue = settings.matrixDensity
        densityLabel?.stringValue = "\(Int(settings.matrixDensity * 100))%"
        
        // Matrix Audio & Interaction
        soundEffectsSwitch?.state = settings.matrixSoundEffects ? .on : .off
        showTimeRemainingSwitch?.state = settings.showTimeRemaining ? .on : .off
    }
    
    // MARK: - Actions
    
    @IBAction func colorDidChange(_ sender: NSColorWell) {
        UserSettings.shared.matrixCharacterColor = sender.color
        presetPopUpButton?.selectItem(withTitle: "Custom")
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func animationSpeedDidChange(_ sender: NSSlider) {
        let speed = sender.doubleValue
        UserSettings.shared.matrixAnimationSpeed = speed
        animationSpeedLabel?.stringValue = String(format: "%.1fx", speed)
        presetPopUpButton?.selectItem(withTitle: "Custom")
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func densityDidChange(_ sender: NSSlider) {
        let density = sender.doubleValue
        UserSettings.shared.matrixDensity = density
        densityLabel?.stringValue = "\(Int(density * 100))%"
        presetPopUpButton?.selectItem(withTitle: "Custom")
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func soundEffectsDidChange(_ sender: NSSwitch) {
        UserSettings.shared.matrixSoundEffects = (sender.state == .on)
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func showTimeRemainingDidChange(_ sender: NSSwitch) {
        UserSettings.shared.showTimeRemaining = (sender.state == .on)
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
    
    @IBAction func presetDidChange(_ sender: NSPopUpButton) {
        guard let selectedTitle = sender.selectedItem?.title else { return }
        
        switch selectedTitle {
        case "Classic Matrix":
            applyPreset(speed: 1.0, density: 0.7, color: NSColor.green)
        case "Fast Rain":
            applyPreset(speed: 2.5, density: 0.9, color: NSColor.green)
        case "Sparse Code":
            applyPreset(speed: 0.8, density: 0.3, color: NSColor.systemBlue)
        case "Dense Storm":
            applyPreset(speed: 1.5, density: 1.0, color: NSColor.systemYellow)
        case "Slow Drip":
            applyPreset(speed: 0.5, density: 0.4, color: NSColor.systemPurple)
        case "Custom":
            break // Don't change anything for custom
        default:
            break
        }
    }
    
    @IBAction func previewPressed(_ sender: NSButton) {
        // Trigger a preview of the Matrix effect with current settings
        NotificationCenter.default.post(name: NSNotification.Name("MatrixPreview"), object: nil)
    }
    
    private func applyPreset(speed: Double, density: Double, color: NSColor) {
        let settings = UserSettings.shared
        
        settings.matrixAnimationSpeed = speed
        settings.matrixDensity = density
        settings.matrixCharacterColor = color
        
        // Update UI
        animationSpeedSlider?.doubleValue = speed
        animationSpeedLabel?.stringValue = String(format: "%.1fx", speed)
        
        densitySlider?.doubleValue = density
        densityLabel?.stringValue = "\(Int(density * 100))%"
        
        characterColorWell?.color = color
        
        // Notify about settings change
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
}
