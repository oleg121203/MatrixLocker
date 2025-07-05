import Cocoa

class LockScreenView: NSView {
    private var characters: [String] = []
    private var columns: [Column] = []
    private var timer: Timer?
    
    private struct Column {
        var characters: [String]
        var position: Int
        let x: CGFloat
        let speed: Double
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
        let katakana = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        characters = katakana.map { String($0) }
        setupColumns()
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateAnimation), userInfo: nil, repeats: true)
    }

    private func setupColumns() {
        let fontSize: CGFloat = 18
        let columnCount = Int(bounds.width / fontSize)
        columns = []
        for i in 0..<columnCount {
            columns.append(Column(
                characters: (0..<Int(bounds.height / fontSize)).map { _ in self.characters.randomElement()! },
                position: Int.random(in: -50...0),
                x: CGFloat(i) * fontSize,
                speed: Double.random(in: 0.5...1.5)
            ))
        }
    }

    @objc private func updateAnimation() {
        for i in 0..<columns.count {
            columns[i].position += Int(columns[i].speed)
            if columns[i].position >= columns[i].characters.count {
                columns[i].position = 0
            }
        }
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.setFill()
        dirtyRect.fill()
        let characterColor = UserSettings.shared.matrixCharacterColor
        let fontSize: CGFloat = 18
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)

        for column in columns {
            for (i, char) in column.characters.enumerated() {
                let y = bounds.height - CGFloat((column.position + i) % column.characters.count) * fontSize
                let isHead = i == (column.characters.count - 1)
                let color = isHead ? .white : characterColor.withAlphaComponent(CGFloat(i) / CGFloat(column.characters.count))
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let point = NSPoint(x: column.x, y: y)
                char.draw(at: point, withAttributes: attrs)
            }
        }
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        setupColumns()
    }

    deinit {
        timer?.invalidate()
    }
}
