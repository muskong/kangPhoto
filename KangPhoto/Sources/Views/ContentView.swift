import SwiftUI
import AppKit

struct ContentView: View {
    @State private var isTracking = false
    @State private var trajectoryPoints: [(x: Double, y: Double, timestamp: Double)] = []
    @State private var analysis: TrajectoryAnalysis?
    @State private var showDebugInfo = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if isTracking {
                        MouseTracker.shared.stopTracking()
                        if let sessionId = MouseTracker.shared.getCurrentSessionId() {
                            trajectoryPoints = DatabaseManager.shared.getTrajectoryData(sessionId: sessionId)
                            analysis = TrajectoryAnalyzer.analyze(points: trajectoryPoints)
                        }
                    } else {
                        MouseTracker.shared.startTracking()
                        trajectoryPoints = []
                        analysis = nil
                    }
                    isTracking.toggle()
                }) {
                    Text(isTracking ? "停止记录" : "开始记录")
                        .padding()
                        .background(isTracking ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    showDebugInfo.toggle()
                }) {
                    Text("调试信息")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            
            if showDebugInfo {
                DebugInfoView(analysis: analysis)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            TrajectoryView(points: trajectoryPoints)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.1))
                .cornerRadius(12)
                .padding()
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

struct DebugInfoView: View {
    let analysis: TrajectoryAnalysis?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let analysis = analysis {
                Group {
                    Text("轨迹分析结果：")
                        .font(.headline)
                    Text("总距离: \(String(format: "%.2f", analysis.totalDistance)) 像素")
                    Text("平均速度: \(String(format: "%.2f", analysis.averageSpeed)) 像素/秒")
                    Text("最大速度: \(String(format: "%.2f", analysis.maxSpeed)) 像素/秒")
                    Text("持续时间: \(String(format: "%.2f", analysis.duration)) 秒")
                    Text("采样点数: \(analysis.pointCount)")
                    Text("方向变化次数: \(analysis.directionChanges)")
                    Text("边界框: (\(String(format: "%.0f", analysis.boundingBox.minX)), \(String(format: "%.0f", analysis.boundingBox.minY))) - (\(String(format: "%.0f", analysis.boundingBox.maxX)), \(String(format: "%.0f", analysis.boundingBox.maxY)))")
                }
                .font(.system(.body, design: .monospaced))
            } else {
                Text("暂无分析数据")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct TrajectoryView: NSViewRepresentable {
    let points: [(x: Double, y: Double, timestamp: Double)]
    
    func makeNSView(context: Context) -> NSView {
        let view = TrajectoryNSView()
        view.points = points
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let view = nsView as? TrajectoryNSView {
            view.points = points
            view.needsDisplay = true
        }
    }
}

class TrajectoryNSView: NSView {
    var points: [(x: Double, y: Double, timestamp: Double)] = []
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard !points.isEmpty else { return }
        
        let path = NSBezierPath()
        path.move(to: NSPoint(x: points[0].x, y: points[0].y))
        
        for point in points.dropFirst() {
            path.line(to: NSPoint(x: point.x, y: point.y))
        }
        
        NSColor.blue.setStroke()
        path.lineWidth = 2
        path.stroke()
    }
}

#Preview {
    ContentView()
} 