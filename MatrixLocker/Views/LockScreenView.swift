import Cocoa

class LockScreenView: NSView {
    private var characters: [String] = []
    private var columns: [MatrixColumn] = []
    private var timer: Timer?
    private var digitalRain: [DigitalRainDrop] = []
    
    private struct MatrixColumn {
        var characters: [MatrixCharacter]
        var x: CGFloat
        var speed: Double
        var lastDropTime: TimeInterval
        var intensity: Double
    }
    
    private struct MatrixCharacter {
        var char: String
        var y: CGFloat
        var brightness: Double
        var isLeading: Bool
        var age: Double
    }
    
    private struct DigitalRainDrop {
        var x: CGFloat
        var y: CGFloat
        var speed: Double
        var length: Int
        var characters: [String]
        var brightness: Double
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // Authentic Matrix characters: Katakana, Latin, numerals, and symbols
        let matrixChars = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
        characters = matrixChars.map { String($0) }
        setupMatrixEffect()
        timer = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(updateAnimation), userInfo: nil, repeats: true)
        
        // Listen for settings changes and preview requests
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange), name: .settingsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(previewEffect), name: NSNotification.Name("MatrixPreview"), object: nil)
    }
    
    @objc private func settingsDidChange() {
        // Force a redraw when settings change
        DispatchQueue.main.async {
            self.needsDisplay = true
        }
    }
    
    @objc private func previewEffect() {
        // Clear current rain and spawn a burst of new drops for preview
        digitalRain.removeAll()
        
        for i in 0..<columns.count {
            if Double.random(in: 0...1) < 0.7 { // 70% chance to spawn a drop in each column
                let drop = DigitalRainDrop(
                    x: columns[i].x,
                    y: -50,
                    speed: columns[i].speed * UserSettings.shared.matrixAnimationSpeed,
                    length: Int.random(in: 8...25),
                    characters: (0..<25).map { _ in characters.randomElement()! },
                    brightness: columns[i].intensity
                )
                digitalRain.append(drop)
            }
        }
        
        DispatchQueue.main.async {
            self.needsDisplay = true
        }
    }

    private func setupMatrixEffect() {
        let fontSize: CGFloat = 14
        let columnWidth: CGFloat = fontSize * 0.8
        let columnCount = Int(bounds.width / columnWidth)
        
        columns = []
        digitalRain = []
        
        for i in 0..<columnCount {
            let column = MatrixColumn(
                characters: [],
                x: CGFloat(i) * columnWidth,
                speed: Double.random(in: 1.0...3.0),
                lastDropTime: 0,
                intensity: Double.random(in: 0.3...1.0)
            )
            columns.append(column)
        }
    }

    @objc private func updateAnimation() {
        let settings = UserSettings.shared
        let speedMultiplier = settings.matrixAnimationSpeed
        let currentTime = CACurrentMediaTime()
        
        // Update existing drops
        for i in stride(from: digitalRain.count - 1, through: 0, by: -1) {
            digitalRain[i].y += CGFloat(digitalRain[i].speed * speedMultiplier)
            digitalRain[i].brightness *= 0.995 // Fade over time
            
            // Remove drops that are off screen or too faded
            if digitalRain[i].y > bounds.height + 100 || digitalRain[i].brightness < 0.1 {
                digitalRain.remove(at: i)
            }
        }
        
        // Randomly spawn new drops based on density setting
        let densityMultiplier = settings.matrixDensity
        for i in 0..<columns.count {
            let timeSinceLastDrop = currentTime - columns[i].lastDropTime
            let spawnChance = densityMultiplier * 0.1 // Base spawn chance adjusted by density
            let shouldSpawn = timeSinceLastDrop > Double.random(in: 0.5...3.0) && Double.random(in: 0...1) < spawnChance
            
            if shouldSpawn {
                let drop = DigitalRainDrop(
                    x: columns[i].x,
                    y: -50,
                    speed: columns[i].speed,
                    length: Int.random(in: 8...25),
                    characters: (0..<25).map { _ in characters.randomElement()! },
                    brightness: columns[i].intensity
                )
                digitalRain.append(drop)
                columns[i].lastDropTime = currentTime
            }
        }
        
        // Randomly change some characters
        for i in 0..<digitalRain.count {
            if Bool.random() && digitalRain[i].characters.count > 0 {
                let randomIndex = Int.random(in: 0..<digitalRain[i].characters.count)
                digitalRain[i].characters[randomIndex] = characters.randomElement()!
            }
        }
        
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        // Deep black background
        NSColor.black.setFill()
        dirtyRect.fill()
        
        let matrixColor = UserSettings.shared.matrixCharacterColor
        let fontSize: CGFloat = 14
        let font = NSFont(name: "Menlo", size: fontSize) ?? NSFont.monospacedSystemFont(ofSize: fontSize, weight: .medium)
        
        // Draw digital rain
        for drop in digitalRain {
            for (index, char) in drop.characters.enumerated() {
                let charY = drop.y - CGFloat(index * Int(fontSize))
                
                // Skip if character is off screen
                guard charY > -fontSize && charY < bounds.height + fontSize else { continue }
                
                // Calculate brightness based on position in drop
                let isLeading = index == 0
                let distanceFromHead = CGFloat(index)
                let maxDistance = CGFloat(drop.length)
                
                var alpha: CGFloat
                var color: NSColor
                
                if isLeading {
                    // Leading character is bright white
                    alpha = CGFloat(drop.brightness)
                    color = NSColor.white
                } else {
                    // Trailing characters fade with matrix color
                    let fadeMultiplier = max(0, 1.0 - (distanceFromHead / maxDistance))
                    alpha = CGFloat(drop.brightness * Double(fadeMultiplier) * 0.8)
                    color = matrixColor
                }
                
                // Add slight random flicker
                if Bool.random() {
                    alpha *= 0.7
                }
                
                let finalColor = color.withAlphaComponent(alpha)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: finalColor,
                    .strokeWidth: -1.0,
                    .strokeColor: finalColor.withAlphaComponent(alpha * 0.3)
                ]
                
                let point = NSPoint(x: drop.x, y: charY)
                char.draw(at: point, withAttributes: attrs)
            }
        }
        
        // Add occasional screen glitch effect
        if Int.random(in: 0...200) == 0 {
            let glitchRect = NSRect(x: 0, y: CGFloat.random(in: 0...bounds.height), 
                                  width: bounds.width, height: 2)
            matrixColor.withAlphaComponent(0.1).setFill()
            glitchRect.fill()
        }
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        setupMatrixEffect()
    }

    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}
