//
//  File.swift
//  
//
//  Created by Paul Calnan on 5/1/20.
//

import Foundation

public class NSLogDestination<Category>: Destination where Category: Hashable & CaseIterable & RawRepresentable, Category.RawValue == String {

    let formatter: MessageFormatter<Category>

    public init(formatter: MessageFormatter<Category> = DefaultMessageFormatter(includeTimestamp: false, includeCategory: true)) {
        self.formatter = formatter
    }

    public func log(_ message: Message<Category>) {
        NSLog("%@", formatter.format(message))
    }
}
