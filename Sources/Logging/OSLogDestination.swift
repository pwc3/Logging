//
//  OSLogDestination.swift
//  Logging
//
//  Copyright (c) 2020 Anodized Software, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation
import os

public class OSLogDestination<CategoryType>: Destination
    where CategoryType: Hashable & CaseIterable & RawRepresentable,
          CategoryType.RawValue == String {

    let formatter: MessageFormatter<CategoryType>

    private let loggers: [CategoryType: OSLog]

    public init(subsystem: String,
                formatter: MessageFormatter<CategoryType> = DefaultMessageFormatter(includeTimestamp: false, includeCategory: false)) {

        self.formatter = formatter

        var loggers = [CategoryType: OSLog]()
        for category in CategoryType.allCases {
            loggers[category] = OSLog(subsystem: subsystem, category: category.rawValue)
        }
        self.loggers = loggers
    }

    public func log(_ message: Message<CategoryType>) {
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
