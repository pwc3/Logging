//
//  CocoaLumberjackLogFormatter.swift
//  CocoaLumberjackFileLogging
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
import Logging

open class CocoaLumberjackLogFormatter<Category>: NSObject, DDLogFormatter where Category: CaseIterable & Hashable & RawRepresentable, Category.RawValue == String {

    private let threadDateFormatterKey: NSString = "Logging.FileMessageFormatter.dateFormatter"

    open var dateFormatterForCurrentThread: DateFormatter {
        let threadDictionary = Thread.current.threadDictionary

        if let df: DateFormatter = threadDictionary.object(forKey: threadDateFormatterKey) as? DateFormatter {
            return df
        }
        else {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"

            threadDictionary.setObject(df, forKey: threadDateFormatterKey)
            return df
        }
    }

    open func format(message: DDLogMessage) -> String? {
        let logLevel: String?
        if message.flag.contains(.error) {
            logLevel = "error"
        }
        else if message.flag.contains(.warning) {
            logLevel = "warning"
        }
        else if message.flag.contains(.info) {
            logLevel = "info"
        }
        else if message.flag.contains(.debug) {
            logLevel = "debug"
        }
        else if message.flag.contains(.verbose) {
            logLevel = "verbose"
        }
        else {
            logLevel = nil
        }

        let context = Category.at(index: message.context)

        var components = [String]()
        logLevel.map { components.append("[\($0)]") }
        components.append("[\(context)]")
        components.append(dateFormatterForCurrentThread.string(from: message.timestamp))

        components.append(contentsOf: [
            String(format: "(%@:%d)", (message.file as NSString).lastPathComponent, message.line),
            message.message
        ])

        return components.joined(separator: " ")
    }
}
