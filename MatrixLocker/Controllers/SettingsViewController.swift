import Cocoa

class SettingsViewController: NSViewController {

    @IBOutlet weak var generalButton: NSButton!
    @IBOutlet weak var xcodeButton: NSButton!
    @IBOutlet weak var aboutButton: NSButton!
    
    // This will be the container for our different settings panes
    @IBOutlet weak var containerView: NSView!
    
    private var currentViewController: NSViewController?
    private var sidebarButtons: [NSButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up button tags for identification
        generalButton?.tag = 0
        xcodeButton?.tag = 1
        aboutButton?.tag = 2
        
        sidebarButtons = [generalButton, xcodeButton, aboutButton].compactMap { $0 }
        
        // Set the initial state - show general settings
        showViewController(withIdentifier: "GeneralSettingsViewController")
        updateSidebar(selectedButton: generalButton)
    }
    
    @IBAction func sidebarButtonTapped(_ sender: NSButton) {
        let identifiers = ["GeneralSettingsViewController", "XcodeSettingsViewController", "AboutViewController"]
        
        if sender.tag < identifiers.count {
            showViewController(withIdentifier: identifiers[sender.tag])
            updateSidebar(selectedButton: sender)
        }
    }
    
    private func showViewController(withIdentifier identifier: String) {
        // Remove current view controller if any
        if let current = currentViewController {
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        // Load new view controller
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let newViewController = storyboard.instantiateController(withIdentifier: identifier) as? NSViewController {
            addChild(newViewController)
            
            // Add the new view to container
            newViewController.view.frame = containerView.bounds
            newViewController.view.autoresizingMask = [.width, .height]
            containerView.addSubview(newViewController.view)
            
            currentViewController = newViewController
        }
    }
    
    private func updateSidebar(selectedButton: NSButton?) {
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
