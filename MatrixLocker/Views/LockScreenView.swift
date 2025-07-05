import UIKit

/// A view that displays a "Matrix rain" style lock screen animation with customizable text and color.
/// The view animates columns of characters that fall down the screen with a fading trail effect.
final class LockScreenView: UIView {
    
    // MARK: - Public Properties
    
    /// The text displayed as a trailing label at the bottom right.
    public var trailingLabelText: String = "" {
        didSet {
            trailingLabel.text = trailingLabelText
            trailingLabel.sizeToFit()
            setNeedsLayout()
        }
    }
    
    /// The color of the trailing text.
    public var trailingLabelColor: UIColor = .green {
        didSet {
            trailingLabel.textColor = trailingLabelColor
        }
    }
    
    /// The color used for the falling characters.
    public var rainColor: UIColor = .green {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The font used for the falling characters.
    /// Falls back to monospaced system font if "Menlo" is unavailable.
    public var rainFont: UIFont = UIFont(name: "Menlo", size: 16.0) ?? UIFont.monospacedSystemFont(ofSize: 16.0, weight: .regular) {
        didSet {
            recalculateCharacterMetrics()
            setNeedsDisplay()
        }
    }
    
    // MARK: - Private Properties
    
    /// The size of each character using the current rainFont.
    private var charSize: CGSize = .zero
    
    /// Number of columns based on view width and character width.
    private var numCols: Int = 0
    
    /// Y positions for each column's falling character.
    private var columnYPositions: [CGFloat] = []
    
    /// Timer driving the animation.
    private var animationTimer: Timer?
    
    /// Label shown at bottom right with trailing text.
    private let trailingLabel = UILabel()
    
    /// The character set used for the "Matrix rain" effect.
    private let rainCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"
    
    /// Flag indicating whether animation is currently running.
    private var isAnimating = false
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    /// Sets up the view's properties and observers.
    private func commonInit() {
        backgroundColor = .black
        isOpaque = true
        
        // Set up trailing label font with fallback.
        trailingLabel.font = UIFont(name: "Menlo-Bold", size: 18) ?? UIFont.monospacedSystemFont(ofSize: 18, weight: .bold)
        trailingLabel.textColor = trailingLabelColor
        trailingLabel.textAlignment = .right
        trailingLabel.backgroundColor = .clear
        trailingLabel.text = trailingLabelText
        trailingLabel.sizeToFit()
        addSubview(trailingLabel)
        
        // Initial calculation of character metrics.
        recalculateCharacterMetrics()
        
        // Observe app lifecycle notifications to pause/resume animation.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }
    
    deinit {
        stopAnimation()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Recalculate character size and columns when bounds change.
        recalculateCharacterMetrics()
        
        // Update trailing label frame to bottom right with padding.
        let padding: CGFloat = 10
        let labelSize = trailingLabel.bounds.size
        trailingLabel.frame = CGRect(
            x: bounds.width - labelSize.width - padding,
            y: bounds.height - labelSize.height - padding,
            width: labelSize.width,
            height: labelSize.height)
    }
    
    /// Recalculates character size, number of columns, and adjusts column Y positions accordingly.
    private func recalculateCharacterMetrics() {
        charSize = "A".size(withAttributes: [.font: rainFont])
        guard charSize.width > 0 else {
            numCols = 0
            columnYPositions.removeAll()
            return
        }
        
        let newNumCols = Int(bounds.width / charSize.width)
        
        if newNumCols != numCols {
            numCols = newNumCols
            // Resize or initialize columnYPositions with random starting Y values within bounds height
            if columnYPositions.count > numCols {
                columnYPositions = Array(columnYPositions.prefix(numCols))
            } else if columnYPositions.count < numCols {
                columnYPositions.append(contentsOf:
                    (0..<(numCols - columnYPositions.count)).map { _ in CGFloat.random(in: 0...bounds.height) }
                )
            }
        }
    }
    
    // MARK: - Animation Control
    
    /// Starts the matrix rain animation.
    public func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        setupTimer()
    }
    
    /// Stops the matrix rain animation.
    public func stopAnimation() {
        guard isAnimating else { return }
        isAnimating = false
        invalidateTimer()
    }
    
    /// Creates and schedules the animation timer.
    private func setupTimer() {
        invalidateTimer()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.animationStep()
        }
        RunLoop.main.add(animationTimer!, forMode: .common)
    }
    
    /// Invalidates and nils out the animation timer.
    private func invalidateTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    // MARK: - Application Lifecycle Handlers
    
    @objc private func applicationDidEnterBackground() {
        invalidateTimer()
    }
    
    @objc private func applicationWillEnterForeground() {
        if isAnimating && animationTimer == nil {
            setupTimer()
        }
    }
    
    // MARK: - Animation Logic
    
    /// Performs one animation step: updates Y positions and triggers view redraw.
    private func animationStep() {
        guard numCols > 0 else { return }
        
        // Update the y position for each column to create falling effect.
        for index in 0..<numCols {
            // Move the position down by one character height.
            columnYPositions[index] += charSize.height
            
            // Reset to top after reaching bottom.
            if columnYPositions[index] > bounds.height {
                columnYPositions[index] = 0
            }
        }
        
        // Trigger redraw.
        setNeedsDisplay()
    }
    
    /// Draws the matrix rain effect.
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), numCols > 0 else { return }
        
        // Fill background black.
        context.setFillColor(UIColor.black.cgColor)
        context.fill(rect)
        
        // Attributes for drawing characters.
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: rainFont,
            .foregroundColor: rainColor
        ]
        
        // Draw each column's falling character.
        for colIndex in 0..<numCols {
            // Randomly pick one character from rainCharacters.
            let randomIndex = rainCharacters.index(
                rainCharacters.startIndex,
                offsetBy: Int.random(in: 0..<rainCharacters.count))
            let char = String(rainCharacters[randomIndex])
            
            let xPos = CGFloat(colIndex) * charSize.width
            let yPos = columnYPositions[colIndex]
            
            char.draw(at: CGPoint(x: xPos, y: yPos), withAttributes: baseAttributes)
            
            // Draw a fading trail above the current character.
            let trailLength = 5
            for trailOffset in 1...trailLength {
                let trailY = yPos - CGFloat(trailOffset) * charSize.height
                if trailY < 0 { break }
                
                // Alpha decreases with trail offset.
                let alpha = CGFloat(trailLength - trailOffset) / CGFloat(trailLength) * 0.7
                
                // Pick random character for trail to enhance variety.
                let trailCharIndex = rainCharacters.index(
                    rainCharacters.startIndex,
                    offsetBy: Int.random(in: 0..<rainCharacters.count))
                let trailChar = String(rainCharacters[trailCharIndex])
                
                let trailAttributes: [NSAttributedString.Key: Any] = [
                    .font: rainFont,
                    .foregroundColor: rainColor.withAlphaComponent(alpha)
                ]
                
                trailChar.draw(at: CGPoint(x: xPos, y: trailY), withAttributes: trailAttributes)
            }
        }
    }
    
    // MARK: - Notes
    
    // For smoother and more precise animation timing consider using CADisplayLink instead of Timer.
}
