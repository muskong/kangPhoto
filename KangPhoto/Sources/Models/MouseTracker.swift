import Foundation
import AppKit

class MouseTracker {
    static let shared = MouseTracker()
    private var isTracking = false
    private var currentSessionId: String?
    private var eventMonitor: Any?
    
    private init() {}
    
    func startTracking() {
        guard !isTracking else { return }
        
        isTracking = true
        currentSessionId = UUID().uuidString
        DebugLogger.shared.info("开始记录鼠标轨迹，会话ID: \(currentSessionId ?? "unknown")")
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            guard let self = self, self.isTracking else { return }
            
            let location = event.locationInWindow
            DatabaseManager.shared.saveMousePosition(
                x: location.x,
                y: location.y,
                sessionId: self.currentSessionId ?? ""
            )
            
            DebugLogger.shared.debug("记录鼠标位置: (\(location.x), \(location.y))")
        }
    }
    
    func stopTracking() {
        guard isTracking else { return }
        
        isTracking = false
        DebugLogger.shared.info("停止记录鼠标轨迹，会话ID: \(currentSessionId ?? "unknown")")
        
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    func getCurrentSessionId() -> String? {
        return currentSessionId
    }
    
    func isCurrentlyTracking() -> Bool {
        return isTracking
    }
} 