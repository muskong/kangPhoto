import Foundation
import os.log

class DebugLogger {
    static let shared = DebugLogger()
    private let logger: Logger
    
    private init() {
        logger = Logger(subsystem: "com.kangphoto", category: "debug")
    }
    
    func log(_ message: String, type: OSLogType = .debug) {
        logger.log(level: type, "\(message)")
    }
    
    func error(_ message: String) {
        logger.error("\(message)")
    }
    
    func info(_ message: String) {
        logger.info("\(message)")
    }
    
    func debug(_ message: String) {
        logger.debug("\(message)")
    }
} 