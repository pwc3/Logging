//
//  AnyFileDestination.swift
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

public class AnyFileDestination<CategoryType>: AnyDestination<CategoryType>, FileDestination {

    private let getMaximumFileSize: () -> UInt64
    private let setMaximumFileSize: (UInt64) -> Void

    private let getRollingFrequency: () -> TimeInterval
    private let setRollingFrequency: (TimeInterval) -> Void

    private let getMaximumNumberOfLogFiles: () -> UInt
    private let setMaximumNumberOfLogFiles: (UInt) -> Void

    private let getLogFilesDiskQuota: () -> UInt64
    private let setLogFilesDiskQuota: (UInt64) -> Void

    private let getLogsDirectory: () -> String

    private let getLogFilePaths: () -> [String]

    private let getCurrentLogFilePath: () -> String?

    private let _rollLogFile: () -> Void

    public init<DestinationType>(fileDestination: DestinationType)
        where DestinationType: FileDestination, DestinationType.CategoryType == CategoryType {

        getMaximumFileSize = { fileDestination.maximumFileSize }
        setMaximumFileSize = { fileDestination.maximumFileSize = $0 }

        getRollingFrequency = { fileDestination.rollingFrequency }
        setRollingFrequency = { fileDestination.rollingFrequency = $0 }

        getMaximumNumberOfLogFiles = { fileDestination.maximumNumberOfLogFiles }
        setMaximumNumberOfLogFiles = { fileDestination.maximumNumberOfLogFiles = $0 }

        getLogFilesDiskQuota = { fileDestination.logFilesDiskQuota }
        setLogFilesDiskQuota = { fileDestination.logFilesDiskQuota = $0 }

        getLogsDirectory = { fileDestination.logsDirectory }
        getLogFilePaths = { fileDestination.logFilePaths }

        getCurrentLogFilePath = { fileDestination.currentLogFilePath }

        _rollLogFile = { fileDestination.rollLogFile() }

        super.init(destination: fileDestination)
    }

    public var maximumFileSize: UInt64 {
        get { return getMaximumFileSize() }
        set { setMaximumFileSize(newValue) }
    }

    public var rollingFrequency: TimeInterval {
        get { return getRollingFrequency() }
        set { setRollingFrequency(newValue) }
    }

    public var maximumNumberOfLogFiles: UInt {
        get { return getMaximumNumberOfLogFiles() }
        set { setMaximumNumberOfLogFiles(newValue) }
    }

    public var logFilesDiskQuota: UInt64 {
        get { return getLogFilesDiskQuota() }
        set { setLogFilesDiskQuota(newValue) }
    }

    public var logsDirectory: String {
        return getLogsDirectory()
    }

    public var logFilePaths: [String] {
        return getLogFilePaths()
    }
    
    public var currentLogFilePath: String? {
        return getCurrentLogFilePath()
    }

    public func rollLogFile() {
        _rollLogFile()
    }
}
