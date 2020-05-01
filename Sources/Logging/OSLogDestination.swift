//
//  File.swift
//  
//
//  Created by Paul Calnan on 4/30/20.
//

import Foundation
import os

public class OSLogDestination<Category>: Destination where Category: Hashable & CaseIterable & RawRepresentable, Category.RawValue == String {

    let formatter: MessageFormatter<Category>

    private let loggers: [Category: OSLog]

    public init(subsystem: String,
                formatter: MessageFormatter<Category> = DefaultMessageFormatter<Category>(includeTimestamp: false, includeCategory: false)) {

        self.formatter = formatter

        var loggers = [Category: OSLog]()
        for category in Category.allCases {
            loggers[category] = OSLog(subsystem: subsystem, category: category.rawValue)
        }
        self.loggers = loggers
    }

    public func log(_ message: Message<Category>) {
        let formatted = formatter.format(message)
        let logger: OSLog! = loggers[message.category]
        os_log("%{public}@", log: logger, type: osLogType(from: message.level), formatted)
    }

    @inlinable func osLogType(from level: Level) -> OSLogType {
        switch level {

        case .error:
            // Error-level messages are always saved in the data store. They remain there until a storage quota is exceeded, at which point, the oldest messages are purged. Error-level messages are intended for reporting process-level errors.
            return .error

        case .warning, .info:
            // Info-level messages are initially stored in memory buffers. Without a configuration change, they are not moved to the data store and are purged as memory buffers fill. They are, however, captured in the data store when faults and, optionally, errors occur. When info-level messages are added to the data store, they remain there until a storage quota is exceeded, at which point, the oldest messages are purged. Use this level to capture information that may be helpful, but isn’t essential, for troubleshooting errors.
            return .info

        case .debug, .verbose:
            // Debug-level messages are only captured in memory when debug logging is enabled through a configuration change. They’re purged in accordance with the configuration’s persistence setting. Messages logged at this level contain information that may be useful during development or while troubleshooting a specific problem. Debug logging is intended for use in a development environment and not in shipping software.
            return .debug
        }
    }
}
