import Foundation
import AppKit

/// Відповідає за звукові ефекти в MatrixLocker
final class SoundManager {
    static let shared = SoundManager()
    
    enum Effect {
        case lock, unlock, failedAttempt
    }
    
    func play(effect: Effect) {
        let soundName: NSSound.Name
        switch effect {
        case .lock: soundName = NSSound.Name("lock_sound")
        case .unlock: soundName = NSSound.Name("unlock_sound")
        case .failedAttempt: soundName = NSSound.Name("fail_sound")
        }
        NSSound(named: soundName)?.play()
    }
}
