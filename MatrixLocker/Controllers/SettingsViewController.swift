import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet weak var generalButton: NSButton!
    @IBOutlet weak var xcodeButton: NSButton!
    @IBOutlet weak var aboutButton: NSButton!
    
    // This will be the container for our different settings panes
    @IBOutlet weak var containerView: NSView!
    
    private var tabViewController: NSTabViewController?
    private var sidebarButtons: [NSButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        sidebarButtons = [generalButton, xcodeButton, aboutButton]
        
        // Find the embedded TabViewController
        for child in children {
            if let vc = child as? NSTabViewController {
                tabViewController = vc
                break
            }
        }
        
        // Set the initial state
        updateSidebar(selectedButton: generalButton)
    }
    
    @IBAction func sidebarButtonTapped(_ sender: NSButton) {
        // Switch tabs and update the UI
        tabViewController?.selectedTabViewItemIndex = sender.tag
        updateSidebar(selectedButton: sender)
    }
    
    private func updateSidebar(selectedButton: NSButton) {
        // Visually update which button is currently selected
        for button in sidebarButtons {
            if button == selectedButton {
                button.contentTintColor = .white
                button.layer?.backgroundColor = NSColor(white: 1.0, alpha: 0.1).cgColor
            } else {
                button.contentTintColor = .lightGray
                button.layer?.backgroundColor = NSColor.clear.cgColor
            }
        }
    }
}
