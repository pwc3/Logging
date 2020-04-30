//
//  DefaultLogger.swift
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

public class Logger<Context> where Context: LogContext {

    let context: Context
    
    public var isEnabled = true
    
    public var minimumLogLevel: LogLevel = .verbose

    init(context: Context) {
        self.context = context
    }
    
    public func log(_ level: LogLevel, _ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        logMessage(message: message(), level: level, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    public func debug(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        logMessage(message: message(), level: .debug, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    public func info(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        logMessage(message: message(), level: .info, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    public func warn(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        logMessage(message: message(), level: .warning, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    public func verbose(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        logMessage(message: message(), level: .verbose, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    public func error(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, asynchronous: Bool = true) {
        logMessage(message: message(), level: .error, file: file, function: function, line: line, asynchronous: asynchronous)
    }

    private func logMessage(message: @autoclosure () -> String,
                            level: LogLevel,
                            file: StaticString,
                            function: StaticString,
                            line: UInt,
                            asynchronous: Bool) {

        guard isEnabled, level >= minimumLogLevel else {
            return
        }
        
        _DDLogMessage(message(),
                      level: level.ddLogLevel,
                      flag: level.ddLogFlag,
                      context: context.index,
                      file: file,
                      function: function,
                      line: line,
                      tag: nil,
                      asynchronous: asynchronous,
                      ddlog: DDLog.sharedInstance)
    }
}
