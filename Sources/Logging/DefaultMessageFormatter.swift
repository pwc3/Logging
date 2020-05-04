//
//  DefaultMessageFormatter.swift
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

public class DefaultMessageFormatter<CategoryType>: MessageFormatter<CategoryType>
    where CategoryType: Hashable & CaseIterable & RawRepresentable, CategoryType.RawValue == String {

    public let includeTimestamp: Bool

    public let includeCategory: Bool

    public init(includeTimestamp: Bool, includeCategory: Bool) {
        self.includeTimestamp = includeTimestamp
        self.includeCategory = includeCategory
    }

    public override func format(_ message: Message<CategoryType>) -> String {
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
