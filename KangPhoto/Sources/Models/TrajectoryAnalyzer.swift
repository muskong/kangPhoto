import Foundation

struct TrajectoryAnalysis {
    let totalDistance: Double
    let averageSpeed: Double
    let maxSpeed: Double
    let duration: Double
    let pointCount: Int
    let boundingBox: (minX: Double, minY: Double, maxX: Double, maxY: Double)
    let directionChanges: Int
}

class TrajectoryAnalyzer {
    static func analyze(points: [(x: Double, y: Double, timestamp: Double)]) -> TrajectoryAnalysis {
        guard points.count >= 2 else {
            return TrajectoryAnalysis(
                totalDistance: 0,
                averageSpeed: 0,
                maxSpeed: 0,
                duration: 0,
                pointCount: points.count,
                boundingBox: (0, 0, 0, 0),
                directionChanges: 0
            )
        }
        
        // 计算总距离和速度
        var totalDistance: Double = 0
        var speeds: [Double] = []
        var directionChanges = 0
        var lastDirection: (dx: Double, dy: Double)?
        
        for i in 1..<points.count {
            let prev = points[i-1]
            let curr = points[i]
            
            let dx = curr.x - prev.x
            let dy = curr.y - prev.y
            let distance = sqrt(dx*dx + dy*dy)
            totalDistance += distance
            
            let timeDiff = curr.timestamp - prev.timestamp
            if timeDiff > 0 {
                let speed = distance / timeDiff
                speeds.append(speed)
            }
            
            // 计算方向变化
            if let lastDir = lastDirection {
                let currentDirection = (dx: dx, dy: dy)
                let angle = calculateAngle(lastDir, currentDirection)
                if angle > 45 { // 如果角度变化超过45度，认为方向发生改变
                    directionChanges += 1
                }
            }
            lastDirection = (dx: dx, dy: dy)
        }
        
        // 计算边界框
        let minX = points.map { $0.x }.min() ?? 0
        let maxX = points.map { $0.x }.max() ?? 0
        let minY = points.map { $0.y }.min() ?? 0
        let maxY = points.map { $0.y }.max() ?? 0
        
        // 计算持续时间
        let duration = points.last!.timestamp - points.first!.timestamp
        
        return TrajectoryAnalysis(
            totalDistance: totalDistance,
            averageSpeed: speeds.isEmpty ? 0 : speeds.reduce(0, +) / Double(speeds.count),
            maxSpeed: speeds.max() ?? 0,
            duration: duration,
            pointCount: points.count,
            boundingBox: (minX, minY, maxX, maxY),
            directionChanges: directionChanges
        )
    }
    
    private static func calculateAngle(_ v1: (dx: Double, dy: Double), _ v2: (dx: Double, dy: Double)) -> Double {
        let dot = v1.dx * v2.dx + v1.dy * v2.dy
        let mag1 = sqrt(v1.dx * v1.dx + v1.dy * v1.dy)
        let mag2 = sqrt(v2.dx * v2.dx + v2.dy * v2.dy)
        
        guard mag1 > 0 && mag2 > 0 else { return 0 }
        
        let cosAngle = dot / (mag1 * mag2)
        let angle = acos(min(max(cosAngle, -1.0), 1.0))
        return angle * 180 / .pi
    }
} 