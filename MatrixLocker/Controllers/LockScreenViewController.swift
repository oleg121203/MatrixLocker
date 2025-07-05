import Cocoa
import LocalAuthentication

protocol LockScreenDelegate: AnyObject {
    func didUnlockScreen()
}

class LockScreenViewController: NSViewController {
    weak var delegate: LockScreenDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let matrixView = LockScreenView(frame: self.view.bounds)
        matrixView.autoresizingMask = [.width, .height]
        self.view.addSubview(matrixView, positioned: .below, relativeTo: nil)
        attemptUnlock()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // You can add a button to re-trigger this if the first attempt fails
    }

    private func attemptUnlock() {
        let context = LAContext()
        var error: NSError?
        let reason = "Authenticate to unlock your session."

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        self?.delegate?.didUnlockScreen()
                    } else {
                        // Handle failure: maybe show a retry button.
                        // For simplicity, we just keep the screen locked.
                        print("Authentication failed.")
                    }
                }
            }
        } else {
            print("Local Authentication not available: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
}
