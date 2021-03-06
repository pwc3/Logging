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

public class LoggingService<CategoryType>
    where CategoryType: Hashable & CaseIterable & RawRepresentable,
          CategoryType.RawValue == String {

    private var loggers: [CategoryType: Logger<CategoryType>]!

    public private(set) var destinations: [AnyDestination<CategoryType>] = []

    public var fileDestinations: [AnyFileDestination<CategoryType>] {
        return destinations.compactMap {
            $0 as? AnyFileDestination<CategoryType>
        }
    }

    public init() {
        self.loggers = {
            var d = [CategoryType: Logger<CategoryType>]()
            for c in CategoryType.allCases {
                d[c] = Logger(parent: self, category: c)
            }
            return d
        }()
    }

    public func add<DestinationType>(destination: DestinationType) where DestinationType: Destination, DestinationType.CategoryType == CategoryType {
        destinations.append(AnyDestination(destination: destination))
    }

    public func add<DestinationType>(fileDestination: DestinationType) where DestinationType: FileDestination, DestinationType.CategoryType == CategoryType {
        destinations.append(AnyFileDestination(fileDestination: fileDestination))
    }

    public func setMinimumLevel(_ level: Level) {
        for logger in loggers.values {
            logger.minimumLevel = level
        }
    }

    internal func log(_ message: Message<CategoryType>) {
        destinations.forEach {
            $0.log(message)
        }
    }

    public func logger(for category: CategoryType) -> Logger<CategoryType> {
        return loggers[category]!
    }

    public subscript(_ category: CategoryType) -> Logger<CategoryType> {
        get {
            return loggers[category]!
        }
    }
}
