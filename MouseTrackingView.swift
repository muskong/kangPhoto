import Cocoa

class MouseTrackingView: NSView {
    private var trackPoints: [NSPoint] = []
    private var isTracking = false
    private var trackingArea: NSTrackingArea?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // 设置视图背景为白色
        wantsLayer = true
        layer?.backgroundColor = NSColor.white.cgColor

        // 添加鼠标跟踪区域
        updateTrackingAreas()

        // 启动定时器以定期更新视图
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.needsDisplay = true
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = trackingArea {
            removeTrackingArea(trackingArea)
        }

        trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow],
            owner: self,
            userInfo: nil
        )

        if let trackingArea = trackingArea {
            addTrackingArea(trackingArea)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        isTracking = true
    }

    override func mouseExited(with event: NSEvent) {
        isTracking = false
    }

    override func mouseMoved(with event: NSEvent) {
        if isTracking {
            let point = convert(event.locationInWindow, from: nil)
            trackPoints.append(point)
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard !trackPoints.isEmpty else { return }

        let path = NSBezierPath()
        path.lineWidth = 2.0

        // 设置轨迹颜色为渐变色
        NSColor.systemBlue.setStroke()

        path.move(to: trackPoints[0])
        for i in 1..<trackPoints.count {
            path.line(to: trackPoints[i])
        }

        path.stroke()

        // 在轨迹点上绘制小圆点
        for point in trackPoints {
            let dotRect = NSRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4)
            let dotPath = NSBezierPath(ovalIn: dotRect)
            NSColor.red.setFill()
            dotPath.fill()
        }
    }

    func clearTrack() {
        trackPoints.removeAll()
        needsDisplay = true
    }

    func saveTrackImage() {
        // 创建保存面板
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.png]
        savePanel.nameFieldStringValue = "鼠标轨迹.png"

        savePanel.beginSheetModal(for: window!) { response in
            if response == .OK, let url = savePanel.url {
                self.exportViewAsImage(to: url)
            }
        }
    }

    private func exportViewAsImage(to url: URL) {
        // 创建图像表示
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else { return }
        cacheDisplay(in: bounds, to: rep)

        // 创建图像
        let image = NSImage(size: bounds.size)
        image.addRepresentation(rep)

        // 将图像保存为PNG
        if let tiffData = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapImage.representation(using: .png, properties: [:]) {
            try? pngData.write(to: url)
        }
    }
}