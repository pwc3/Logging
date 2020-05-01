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

public class LoggingService<Category>
    where Category: Hashable & CaseIterable & RawRepresentable,
    Category.RawValue == String {

    private var loggers: [Category: Logger<Category>]!

    private(set) var destinations: [AnyDestination<Category>] = []

    public init() {
        self.loggers = {
            var d = [Category: Logger<Category>]()
            for c in Category.allCases {
                d[c] = Logger(parent: self, category: c)
            }
            return d
        }()
    }

    public func add<DestinationType>(destination: DestinationType) where DestinationType: Destination, DestinationType.Category == Category {
        destinations.append(AnyDestination(destination: destination))
    }

    public func add<DestinationType>(fileDestination: DestinationType) where DestinationType: FileDestination, DestinationType.Category == Category {
        destinations.append(AnyFileDestination(fileDestination: fileDestination))
    }

    public func setMinimumLevel(_ level: Level) {
        for logger in loggers.values {
            logger.minimumLevel = level
        }
    }

    internal func log(_ message: Message<Category>) {
        destinations.forEach {
            $0.log(message)
        }
    }

    public subscript(_ category: Category) -> Logger<Category> {
        get {
            return loggers[category]!
        }
    }
}
