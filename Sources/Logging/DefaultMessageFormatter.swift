//
//  File.swift
//  
//
//  Created by Paul Calnan on 4/30/20.
//

import Foundation

public class DefaultMessageFormatter<Category>: MessageFormatter<Category> where Category: Hashable & CaseIterable & RawRepresentable, Category.RawValue == String {

    public let includeTimestamp: Bool

    public let includeCategory: Bool

    public init(includeTimestamp: Bool, includeCategory: Bool) {
        self.includeTimestamp = includeTimestamp
        self.includeCategory = includeCategory
    }

    public override func format(_ message: Message<Category>) -> String {
        let components: [String?] = [
            "[\(message.level)]",
            includeCategory
                ? "[\(message.category)]"
                : nil,
            includeTimestamp
                ? dateFormatterForCurrentThread.string(from: message.timestamp)
                : nil,
            String(format: "(%@:%d)", NSString(stringLiteral: message.file).lastPathComponent, message.line),
            message.message
        ]

        return components.compactMap({ $0 }).joined(separator: " ")
    }
}
