import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet weak var launchAtLoginSwitch: NSSwitch?
    @IBOutlet weak var hideFromDockSwitch: NSSwitch?
    @IBOutlet weak var startMinimizedSwitch: NSSwitch?

    @IBOutlet weak var matrixServerField: NSTextField?
    @IBOutlet weak var matrixUsernameField: NSTextField?
    @IBOutlet weak var matrixPasswordField: NSSecureTextField?

    @IBOutlet weak var securityLevelPopup: NSPopUpButton?
    @IBOutlet weak var enableFirewallSwitch: NSSwitch?
    @IBOutlet weak var firewallExceptionsField: NSTextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        setAccessibilityElementsOrder()
    }

    private func setAccessibilityElementsOrder() {
        let generalTabElements = [
            launchAtLoginSwitch,
            hideFromDockSwitch,
            startMinimizedSwitch
        ].compactMap { $0 }
        view.setAccessibilityChildren(generalTabElements)

        let matrixTabElements = [
            matrixServerField,
            matrixUsernameField,
            matrixPasswordField
        ].compactMap { $0 }
        view.setAccessibilityChildren(matrixTabElements)

        let securityTabElements = [
            securityLevelPopup,
            enableFirewallSwitch,
            firewallExceptionsField
        ].compactMap { $0 }
        view.setAccessibilityChildren(securityTabElements)
    }
}
