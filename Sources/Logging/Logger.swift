//
//  Logger.swift
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

/// `Logger` objects are created by the `LoggingService`. One `Logger` is created for each value in the generic `CategoryType` String enum used to create the `LoggingService`.
///
/// Each `Logger` maintains an `unowned` reference back to the parent `LoggingService`.
///
/// The application selects a `Logger` using the `LoggingService.subscript` operator or the `LoggingService.logger(for:)` function. It then sends log messages to the `Logger` using the `verbose`, `debug`, `info`, `warn`, and `error` functions.
///
/// These functions each correspond to a `Level` indicating the severity of the message. The `Logger` filters out messages that do not meet the `minimumLevel` set on the `Logger`.
///
/// Each `Logger` can be enabled or disabled via the `isEnabled` flag. Disabled `Logger` objects drop all log messages.
///
/// The `Logger` routes all filtered log messages back to its parent `LoggingService` for them to be sent to the added destinations.
///
/// Note that the message string passed to the logging functions is captured as a `@autoclosure` parameter. This closure will only be evaluated if the message is not filtered out (i.e., it will only be evaluated if the `level` is greater than or equal to the `minimumLevel` and `isEnabled` is `true`).
public class Logger<CategoryType> where CategoryType: CaseIterable & Hashable & RawRepresentable, CategoryType.RawValue == String {

    /// Unowned parent reference. Used to dispatch filtered `Message` values to `Destination` objects.
    internal unowned let parent: LoggingService<CategoryType>

    /// The category of this `Logger`.
    public let category: CategoryType

    /// Flag indicating whether this `Logger` is enabled. If this flag is `false`, all log messages will be dropped.
    public var isEnabled = true

    /// The minimum level for messages to be emitted. If the level of a message is less than the `minimumLevel`, it is dropped.
    public var minimumLevel: Level = .verbose

    /// Creates a new `Logger` with the specified parent and category.
    ///
    /// - parameter parent: The parent logging service. The `Logger` maintains an unowned reference to this object.
    /// - parameter category: The category for this `Logger`.
    internal init(parent: LoggingService<CategoryType>, category: CategoryType) {
        self.parent = parent
        self.category = category
    }

    /// Emits a `verbose` level log message. This message will be logged by the parent `LoggingService` if this `Logger` is enabled (i.e., `isEnabled` is `true`) and the `minimumLevel` is greater than or equal to `.verbose`. Otherwise this message will be dropped.
    ///
    /// - parameter message: The message to be logged.
    /// - parameter file: The filename of the call site. Default: `#file`.
    /// - parameter function: The function containing the call site. Default: `#function`.
    /// - parameter line: The line number of the call site. Default: `#line`.
    public func verbose(_ message: @autoclosure () -> String,
                        file: StaticString = #file,
                        function: StaticString = #function,
                        line: UInt = #line) {
        log(message: message, level: .verbose, file: file, function: function, line: line)
    }

    /// Emits a `debug` level log message. This message will be logged by the parent `LoggingService` if this `Logger` is enabled (i.e., `isEnabled` is `true`) and the `minimumLevel` is greater than or equal to `.debug`. Otherwise this message will be dropped.
    ///
    /// - parameter message: The message to be logged.
    /// - parameter file: The filename of the call site. Default: `#file`.
    /// - parameter function: The function containing the call site. Default: `#function`.
    /// - parameter line: The line number of the call site. Default: `#line`.
    public func debug(_ message: @autoclosure () -> String,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        log(message: message, level: .debug, file: file, function: function, line: line)
    }

    /// Emits an `info` level log message. This message will be logged by the parent `LoggingService` if this `Logger` is enabled (i.e., `isEnabled` is `true`) and the `minimumLevel` is greater than or equal to `.info`. Otherwise this message will be dropped.
    ///
    /// - parameter message: The message to be logged.
    /// - parameter file: The filename of the call site. Default: `#file`.
    /// - parameter function: The function containing the call site. Default: `#function`.
    /// - parameter line: The line number of the call site. Default: `#line`.
    public func info(_ message: @autoclosure () -> String,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
        log(message: message, level: .info, file: file, function: function, line: line)
    }

    /// Emits a `warning` level log message. This message will be logged by the parent `LoggingService` if this `Logger` is enabled (i.e., `isEnabled` is `true`) and the `minimumLevel` is greater than or equal to `.warning`. Otherwise this message will be dropped.
    ///
    /// - parameter message: The message to be logged.
    /// - parameter file: The filename of the call site. Default: `#file`.
    /// - parameter function: The function containing the call site. Default: `#function`.
    /// - parameter line: The line number of the call site. Default: `#line`.
    public func warn(_ message: @autoclosure () -> String,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
        log(message: message, level: .warning, file: file, function: function, line: line)
    }

    /// Emits an `error` level log message. This message will be logged by the parent `LoggingService` if this `Logger` is enabled (i.e., `isEnabled` is `true`) and the `minimumLevel` is greater than or equal to `.error`. Otherwise this message will be dropped.
    ///
    /// - parameter message: The message to be logged.
    /// - parameter file: The filename of the call site. Default: `#file`.
    /// - parameter function: The function containing the call site. Default: `#function`.
    /// - parameter line: The line number of the call site. Default: `#line`.
    public func error(_ message: @autoclosure () -> String,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        log(message: message, level: .error, file: file, function: function, line: line)
    }

    /// Filters out log messages that do not meet the minimum level or if `isEnabled` is `false`. Otherwise, constructs a `Message` and passes it back to the parent for dispatch to the added destinations.
    private func log(message: () -> String,
                     level: Level,
                     file: StaticString,
                     function: StaticString,
                     line: UInt) {

        guard isEnabled, level >= minimumLevel else {
            return
        }

        let message = Message(timestamp: Date(),
                              message: message(),
                              level: level,
                              category: category,
                              file: file,
                              function: function,
                              line: line)
        parent.log(message)
    }
}
