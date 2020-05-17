//
//  LoggingService.swift
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

/// The main interface into the logging service.
///
/// Your application should create a single instance of this class. Usually this is a global variable called `log`.
///
/// The logging service must have one or more `Destination` objects added to it. Without doing this, no log messages will actually appear. There are two destinations provided by this library: `NSLogDestination` and `OSLogDestination`.
///
/// The `LoggingService` class has a generic type parameter `CategoryType`. This corresponds to the log category. You need to provide this type as a String enum that is `CaseIterable`. Logging categories allow you to categorize your log messages. It's up to you to decide what and how many categories you use. The choice is largely dependent upon the application. For example, you may have an `api` category for remote API calls, a `ui` category for user-interface code, an `app` category for application-lifecycle messages. You can then control the verbosity (log level) of each category independently. The log output is formatted in such a way that it is easy to filter specific categories, allowing you to focus on a specific category you are working on or troubleshooting.
///
/// The `CategoryType` is used to construct `Logger` objects, one per value in the enum. These values are accessible via the `subscript` operator and the `logger(for:)` function. The application logs messages via these `Logger` objects. For example:
///
/// ```
/// import Logging
///
/// enum Category: String, CaseIterable {
///     case app
///     case ui
/// }
///
/// let log: LoggingService<Category> = {
///     let service = LoggingService<Category>()
///     service.add(destination: NSLogDestination())
/// }()
///
/// log[.app].debug("This is a debug message sent to the .app category")
/// log.logger(for: .ui).info("This is an info message sent to the .ui category")
/// ```
///
/// Each `Logger` object has a `minimumLevel`. Log messages with a `level` less than the `minimumLevel` shall be filtered out. This `minimumLevel` can be set independently on each `Logger`, or all at once via the `setMinimumLevel(_:)` function.
public class LoggingService<CategoryType>
    where CategoryType: Hashable & CaseIterable & RawRepresentable,
          CategoryType.RawValue == String {

    /// Dictionary mapping every `CategoryType` value to a `Logger`.
    private var loggers: [CategoryType: Logger<CategoryType>]!

    /// This array contains all destinations added to the logging service. These are stored using the type-erased `AnyDestination` type.
    public private(set) var destinations: [AnyDestination<CategoryType>] = []

    /// Computed property that returns `FileDestination` objects added to the logging service.
    public var fileDestinations: [AnyFileDestination<CategoryType>] {
        return destinations.compactMap {
            $0 as? AnyFileDestination<CategoryType>
        }
    }

    /// Creates a new logging service. Note that destinations must be added to the service for log messages to be emitted.
    public init() {
        self.loggers = {
            var d = [CategoryType: Logger<CategoryType>]()
            for c in CategoryType.allCases {
                d[c] = Logger(parent: self, category: c)
            }
            return d
        }()
    }

    /// Adds the specified destination to the logging service.
    ///
    /// - parameter destination: The destination to add to the logging service.
    public func add<DestinationType>(destination: DestinationType) where DestinationType: Destination, DestinationType.CategoryType == CategoryType {
        destinations.append(AnyDestination(destination: destination))
    }

    /// Adds the specified file destination to the logging service.
    ///
    /// - parameter fileDestination: The file destination to add to the logging service.
    public func add<DestinationType>(fileDestination: DestinationType) where DestinationType: FileDestination, DestinationType.CategoryType == CategoryType {
        destinations.append(AnyFileDestination(fileDestination: fileDestination))
    }

    /// Sets the minimum log level. Iterates over the loggers (one per category) and sets their `minimumLevel`. This will overwrite any existing `minimumLevel` setting already set on an individual logger. Any messages with a log level less than the minimum log level will be dropped by the logger.
    ///
    /// - parameter level: The new minimum log level.
    public func setMinimumLevel(_ level: Level) {
        for logger in loggers.values {
            logger.minimumLevel = level
        }
    }

    /// Internal function called by `Logger` objects to dispatch log messages to the registered destinations. The calling `Logger` object shall have already filtered out messages that do not meet the minimum log level.
    ///
    /// - parameter message: The log message to pass to the registered destinations.
    internal func log(_ message: Message<CategoryType>) {
        destinations.forEach {
            $0.log(message)
        }
    }

    /// Returns the logger for the specified category.
    ///
    /// - parameter category: The log category.
    /// - returns: The logger for the specified category.
    public func logger(for category: CategoryType) -> Logger<CategoryType> {
        return loggers[category]!
    }

    /// Returns the logger for the given category. Equivalent to calling `logger(for:)` passing the subscript value.
    ///
    /// - parameter category: The log category.
    /// - returns: The logger for the specified category.
    public subscript(_ category: CategoryType) -> Logger<CategoryType> {
        get {
            return loggers[category]!
        }
    }
}
