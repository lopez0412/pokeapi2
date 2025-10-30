//
//  Logger.swift
//  pokeapi2
//
//  Created by Javier Alejandro Lorenzana Lopez on 10/26/25.
//

import Foundation
import os.log

/// Centralized logging utility for the application
/// Uses OSLog for better performance and filtering
final class AppLogger {
    
    // MARK: - Subsystems
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.pokeapi2"
    
    // MARK: - Loggers by Category
    
    static let network = Logger(subsystem: subsystem, category: "Network")
    static let storage = Logger(subsystem: subsystem, category: "Storage")
    static let background = Logger(subsystem: subsystem, category: "BackgroundTask")
    static let viewModel = Logger(subsystem: subsystem, category: "ViewModel")
    static let notification = Logger(subsystem: subsystem, category: "Notification")
    static let general = Logger(subsystem: subsystem, category: "General")
    
    // MARK: - Convenience Methods
    
    /// Log info message
    static func info(_ message: String, category: LogCategory = .general) {
        #if DEBUG
        logger(for: category).info("\(message)")
        #endif
    }
    
    /// Log debug message (only in DEBUG builds)
    static func debug(_ message: String, category: LogCategory = .general) {
        #if DEBUG
        logger(for: category).debug("\(message)")
        #endif
    }
    
    /// Log error message
    static func error(_ message: String, error: Error? = nil, category: LogCategory = .general) {
        let fullMessage = error != nil ? "\(message): \(error!.localizedDescription)" : message
        logger(for: category).error("\(fullMessage)")
    }
    
    /// Log warning message
    static func warning(_ message: String, category: LogCategory = .general) {
        logger(for: category).warning("\(message)")
    }
    
    /// Log success message (custom level)
    static func success(_ message: String, category: LogCategory = .general) {
        #if DEBUG
        logger(for: category).info("✅ \(message)")
        #endif
    }
    
    // MARK: - Private Helpers
    
    private static func logger(for category: LogCategory) -> Logger {
        switch category {
        case .network: return network
        case .storage: return storage
        case .background: return background
        case .viewModel: return viewModel
        case .notification: return notification
        case .general: return general
        }
    }
}

// MARK: - Log Categories

enum LogCategory {
    case network
    case storage
    case background
    case viewModel
    case notification
    case general
}

// MARK: - Convenient Extensions

extension AppLogger {
    /// Log network request
    static func logRequest(endpoint: String, method: String = "GET") {
        debug("[\(method)] \(endpoint)", category: .network)
    }
    
    /// Log network response
    static func logResponse(statusCode: Int, endpoint: String) {
        if (200...299).contains(statusCode) {
            success("[\(statusCode)] \(endpoint)", category: .network)
        } else {
            error("[\(statusCode)] \(endpoint)", category: .network)
        }
    }
    
    /// Log storage operation
    static func logStorage(operation: String, success: Bool) {
        if success {
            self.success("\(operation)", category: .storage)
        } else {
            error("\(operation) failed", category: .storage)
        }
    }
}
