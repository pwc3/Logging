//
//  CocoaLumberjackFileDestination.swift
//  CocoaLumberjackFileLogging
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
import Logging

public class CocoaLumberjackFileDestination<Category>: FileDestination where Category: Hashable & CaseIterable & RawRepresentable, Category.RawValue == String {

    private let logger: DDFileLogger

    public init(createNewLogFile: Bool = false, formatter: CocoaLumberjackLogFormatter<Category> = CocoaLumberjackLogFormatter()) {
        logger = DDFileLogger()
        logger.doNotReuseLogFiles = createNewLogFile
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
    
    public var currentLogFilePath: String? {
        logger.currentLogFileInfo?.filePath
    }

    public func rollLogFile() {
        logger.rollLogFile(withCompletion: nil)
    }
}
