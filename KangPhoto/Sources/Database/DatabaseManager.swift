import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("mouse_trajectory.sqlite")
        
        DebugLogger.shared.info("数据库路径: \(fileURL.path)")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            DebugLogger.shared.error("无法打开数据库")
            return
        }
        
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS mouse_trajectory (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                x_position REAL NOT NULL,
                y_position REAL NOT NULL,
                timestamp REAL NOT NULL,
                session_id TEXT NOT NULL
            );
        """
        
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                DebugLogger.shared.info("成功创建数据库表")
            } else {
                DebugLogger.shared.error("无法创建数据库表")
            }
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func saveMousePosition(x: Double, y: Double, sessionId: String) {
        let insertQuery = "INSERT INTO mouse_trajectory (x_position, y_position, timestamp, session_id) VALUES (?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_double(insertStatement, 1, x)
            sqlite3_bind_double(insertStatement, 2, y)
            sqlite3_bind_double(insertStatement, 3, Date().timeIntervalSince1970)
            sqlite3_bind_text(insertStatement, 4, (sessionId as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                DebugLogger.shared.debug("成功保存鼠标位置: (\(x), \(y))")
            } else {
                DebugLogger.shared.error("无法保存鼠标位置")
            }
        }
        sqlite3_finalize(insertStatement)
    }
    
    func getTrajectoryData(sessionId: String) -> [(x: Double, y: Double, timestamp: Double)] {
        var trajectoryData: [(x: Double, y: Double, timestamp: Double)] = []
        let query = "SELECT x_position, y_position, timestamp FROM mouse_trajectory WHERE session_id = ? ORDER BY timestamp;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (sessionId as NSString).utf8String, -1, nil)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let x = sqlite3_column_double(statement, 0)
                let y = sqlite3_column_double(statement, 1)
                let timestamp = sqlite3_column_double(statement, 2)
                trajectoryData.append((x: x, y: y, timestamp: timestamp))
            }
            
            DebugLogger.shared.info("获取轨迹数据: \(trajectoryData.count) 个点")
        }
        sqlite3_finalize(statement)
        return trajectoryData
    }
    
    deinit {
        sqlite3_close(db)
        DebugLogger.shared.info("数据库连接已关闭")
    }
} 