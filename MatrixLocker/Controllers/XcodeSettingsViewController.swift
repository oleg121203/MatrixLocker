import Cocoa

class XcodeSettingsViewController: NSViewController {

    @IBOutlet var scriptTextView: NSTextView!
    
    let xcodeSetupScript = """
    #!/bin/bash
    # Xcode Configuration Script
    # Sets sensible defaults for a better development experience.

    echo "🚀 Starting Xcode configuration..."

    # --- Editor Settings ---
    # Show line numbers
    defaults write com.apple.dt.Xcode DVTTextShowLineNumbers -bool true

    # Set tab width to 4 spaces
    defaults write com.apple.dt.Xcode DVTTextIndentWidth -int 4
    defaults write com.apple.dt.Xcode DVTTextTabWidth -int 4

    # Trim trailing whitespace
    defaults write com.apple.dt.Xcode DVTTextEditorTrimTrailingWhitespace -bool true

    # Include whitespace-only lines
    defaults write com.apple.dt.Xcode DVTTextEditorTrimWhitespaceOnlyLines -bool true

    # Show code folding ribbon
    defaults write com.apple.dt.Xcode DVTTextShowCodeFolding -bool true

    # --- Build Settings ---
    # Show build times in the activity viewer
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool true

    echo "✅ Xcode configuration applied."
    echo "⚠️ Please restart Xcode for all changes to take effect."
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the text view to display the script
        scriptTextView.string = xcodeSetupScript
        scriptTextView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        scriptTextView.backgroundColor = NSColor(named: "CodeBlockBackground") ?? .black
        scriptTextView.textColor = .lightGray
    }
    
    @IBAction func copyScriptButtonTapped(_ sender: NSButton) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(xcodeSetupScript, forType: .string)
        
        // Optional: Show a confirmation to the user
        print("Script copied to clipboard!")
        showToast(message: "Script copied to clipboard!")
    }
    
    private func showToast(message: String) {
        // A simple way to show feedback. In a real app, you might use a custom view.
        let toastLabel = NSTextField(labelWithString: message)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.backgroundColor = NSColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = .white
        toastLabel.alignment = .center
        toastLabel.font = .systemFont(ofSize: 14)
        toastLabel.layer?.cornerRadius = 10
        toastLabel.layer?.masksToBounds = true
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            toastLabel.widthAnchor.constraint(equalToConstant: 250),
            toastLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            toastLabel.animator().alphaValue = 1.0
        }, completionHandler: {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                context.delay = 2.0
                toastLabel.animator().alphaValue = 0.0
            }, completionHandler: {
                toastLabel.removeFromSuperview()
            })
        })
    }
}
