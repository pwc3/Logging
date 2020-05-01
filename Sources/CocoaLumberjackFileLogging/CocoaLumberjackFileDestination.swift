//
//  File.swift
//  
//
//  Created by Paul Calnan on 5/1/20.
//

import CocoaLumberjackSwift
import Foundation
import Logging

public class CocoaLumberjackFileDestination<Category>: FileDestination where Category: Hashable & CaseIterable & RawRepresentable, Category.RawValue == String {

    private let logger: DDFileLogger

    public init(formatter: CocoaLumberjackLogFormatter<Category> = CocoaLumberjackLogFormatter()) {
        logger = DDFileLogger()
        logger.logFormatter = formatter

        DDLog.add(logger)
    }

    public func log(_ message: Message<Category>) {
        _DDLogMessage(message.message,
                      level: ddLogLevel(from: message.level),
                      flag: ddLogFlag(from: message.level),
                      context: message.category.index,
                      file: message.file,
                      function: message.function,
                      line: message.line,
                      tag: nil,
                      asynchronous: true,
                      ddlog: DDLog.sharedInstance)
    }

    private func ddLogLevel(from level: Level) -> DDLogLevel {
        switch level {

        case .verbose:
            return .verbose

        case .debug:
            return .debug

        case .info:
            return .info

        case .warning:
            return .warning

        case .error:
            return .error
        }
    }

    private func ddLogFlag(from level: Level) -> DDLogFlag {
        switch level {

        case .verbose:
            return .verbose

        case .debug:
            return .debug

        case .info:
            return .info

        case .warning:
            return .warning

        case .error:
            return .error
        }
    }

    public var maximumFileSize: UInt64 {
        get {
            return logger.maximumFileSize
        }

        set {
            logger.maximumFileSize = newValue
        }
    }

    public var rollingFrequency: TimeInterval {
        get {
            return logger.rollingFrequency
        }

        set {
            logger.rollingFrequency = newValue
        }
    }

    public var maximumNumberOfLogFiles: UInt {
        get {
            return logger.logFileManager.maximumNumberOfLogFiles
        }

        set {
            logger.logFileManager.maximumNumberOfLogFiles = newValue
        }
    }

    public var logFilesDiskQuota: UInt64 {
        get {
            return logger.logFileManager.logFilesDiskQuota
        }

        set {
            logger.logFileManager.logFilesDiskQuota = newValue
        }
    }

    public var logsDirectory: String {
        return logger.logFileManager.logsDirectory
    }

    public var logFilePaths: [String] {
        return logger.logFileManager.sortedLogFilePaths
    }

    public func rollLogFile() {
        logger.rollLogFile(withCompletion: nil)
    }
}
