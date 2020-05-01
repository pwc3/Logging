//
//  File.swift
//  
//
//  Created by Paul Calnan on 4/30/20.
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
