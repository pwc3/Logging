//
//  LogService.swift
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

import CocoaLumberjackSwift
import Foundation

public class LogService<Context> where Context: LogContext {

    public enum OSLoggingConfiguration {

        case `default`(formatter: LogFormatter<Context>)

        case custom(formatter: LogFormatter<Context>, subsystem: String, category: String)
    }

    public struct FileLoggingConfiguration {

        public var formatter: LogFormatter<Context>

        public var maxFileSize: UInt64

        public var rollingFrequency: TimeInterval

        public var maxNumberOfLogFiles: UInt

        public var logFilesDiskQuota: UInt64

        public init(formatter: LogFormatter<Context> = LogFormatter(includeTimestamp: true),
                    maxFileSize: UInt64 = kDDDefaultLogMaxFileSize,
                    rollingFrequency: TimeInterval = kDDDefaultLogRollingFrequency,
                    maxNumberOfLogFiles: UInt = kDDDefaultLogMaxNumLogFiles,
                    logFilesDiskQuota: UInt64 = kDDDefaultLogFilesDiskQuota) {

            self.formatter = formatter
            self.maxFileSize = maxFileSize
            self.rollingFrequency = rollingFrequency
            self.maxNumberOfLogFiles = maxNumberOfLogFiles
            self.logFilesDiskQuota = logFilesDiskQuota
        }
    }
    
    private let osLogger: DDOSLogger?

    public var isOSLogDestinationCofigured: Bool {
        return osLogger != nil
    }

    private let fileLogger: DDFileLogger?

    public var isFileLogDestinationConfigured: Bool {
        return fileLogger != nil
    }
    
    private let perContextLoggers: [Context: Logger<Context>]

    public init(osLogDestination: OSLoggingConfiguration? = .default(formatter: LogFormatter(includeTimestamp: false)),
                fileLogDestination: FileLoggingConfiguration? = nil) {

        if osLogDestination == nil && fileLogDestination == nil {
            fatalError("Must specify at least one logging destination")
        }

        if let os = osLogDestination {
            let osLogger: DDOSLogger

            switch os {
            case .default(let formatter):
                osLogger = DDOSLogger(subsystem: nil, category: nil)
                osLogger.logFormatter = formatter

            case .custom(let formatter, let subsystem, let category):
                osLogger = DDOSLogger(subsystem: subsystem, category: category)
                osLogger.logFormatter = formatter
            }

            DDLog.add(osLogger)
            self.osLogger = osLogger
        }
        else {
            osLogger = nil
        }

        if let file = fileLogDestination {
            let fileLogger = DDFileLogger()
            fileLogger.maximumFileSize = file.maxFileSize
            fileLogger.rollingFrequency = file.rollingFrequency
            fileLogger.logFileManager.maximumNumberOfLogFiles = file.maxNumberOfLogFiles
            fileLogger.logFileManager.logFilesDiskQuota = file.logFilesDiskQuota

            DDLog.add(fileLogger)
            self.fileLogger = fileLogger
        }
        else {
            fileLogger = nil
        }

        var loggers = [Context: Logger<Context>]()
        for c in Context.allCases {
            loggers[c] = Logger<Context>(context: c)
        }
        perContextLoggers = loggers
    }

    public subscript(_ context: Context) -> Logger<Context> {
        // Okay to force unwrap -- we are guaranteed that every Context value is in the dictionary.
        return perContextLoggers[context]!
    }
    
    public func setMinimumLogLevel(_ level: LogLevel) {
        perContextLoggers.values.forEach {
            $0.minimumLogLevel = level
        }
    }
}

// MARK: - File Logger Properties

public extension LogService {

    func rollLogFile(completion: (() -> Void)? = nil) {
        fileLogger?.rollLogFile(withCompletion: completion)
    }

    var logsDirectory: String? {
        return fileLogger?.logFileManager.logsDirectory
    }

    var unsortedLogFilePaths: [String]? {
        return fileLogger?.logFileManager.unsortedLogFilePaths
    }

    var sortedLogFilePaths: [String]? {
        return fileLogger?.logFileManager.sortedLogFilePaths
    }
}
