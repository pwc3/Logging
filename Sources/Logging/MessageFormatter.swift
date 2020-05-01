//
//  File.swift
//  
//
//  Created by Paul Calnan on 4/30/20.
//

import Foundation

open class MessageFormatter<Category> {

    private let threadDateFormatterKey: NSString = "Logging.MessageFormatter.dateFormatter"

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

    open func format(_ message: Message<Category>) -> String {
        return message.message
    }
}
