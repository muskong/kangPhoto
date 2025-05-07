import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var trackingView: MouseTrackingView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建窗口
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "鼠标轨迹记录器"
        window.center()

        // 创建工具栏
        let toolbar = NSToolbar(identifier: "MainToolbar")
        toolbar.displayMode = .iconAndLabel
        toolbar.delegate = self
        window.toolbar = toolbar

        // 创建鼠标轨迹视图
        trackingView = MouseTrackingView(frame: window.contentView!.bounds)
        trackingView.autoresizingMask = [.width, .height]
        window.contentView?.addSubview(trackingView)

        window.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// 工具栏代理实现
extension AppDelegate: NSToolbarDelegate {
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier.rawValue {
        case "ClearTrack":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "清除轨迹"
            item.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "清除")
            item.action = #selector(clearTrack)
            return item

        case "SaveTrack":
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "保存轨迹"
            item.image = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: "保存")
            item.action = #selector(saveTrack)
            return item

        default:
            return nil
        }
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            NSToolbarItem.Identifier("ClearTrack"),
            NSToolbarItem.Identifier("SaveTrack")
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }

    @objc func clearTrack() {
        trackingView.clearTrack()
    }

    @objc func saveTrack() {
        trackingView.saveTrackImage()
    }
}