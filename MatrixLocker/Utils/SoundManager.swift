import Cocoa
import AVFoundation

/// Manages the playback of sound effects for the application.
final class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    private init() {}

    enum SoundEffect {
        case lock
        case unlock
        case failedAttempt
    }
    
    /// Plays a specified sound effect if sound effects are enabled in user settings.
    ///
    /// - Parameter effect: The `SoundEffect` to play.
    func play(effect: SoundEffect) {
        guard UserSettings.shared.matrixSoundEffects else { return }

        var soundName: String?
        
        switch effect {
        case .lock:
            soundName = "Tink" // Example system sound
        case .unlock:
            soundName = "Submarine" // Example system sound
        case .failedAttempt:
            soundName = "Basso" // Example system sound
        }
        
        if let soundName = soundName, let sound = NSSound(named: soundName) {
            sound.play()
        }
    }
}
