//
//  File.swift
//  
//
//  Created by Paul Calnan on 5/1/20.
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
