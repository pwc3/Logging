//
//  Logger.swift
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

public class Logger<CategoryType> where CategoryType: CaseIterable & Hashable & RawRepresentable, CategoryType.RawValue == String {

    internal unowned let parent: LoggingService<CategoryType>

    public let category: CategoryType

    public var isEnabled = true
    
    public var minimumLevel: Level = .verbose

    init(parent: LoggingService<CategoryType>, category: CategoryType) {
        self.parent = parent
        self.category = category
    }

    public func verbose(_ message: @autoclosure () -> String,
                        file: StaticString = #file,
                        function: StaticString = #function,
                        line: UInt = #line) {
        log(message: message, level: .verbose, file: file, function: function, line: line)
    }

    public func debug(_ message: @autoclosure () -> String,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        log(message: message, level: .debug, file: file, function: function, line: line)
    }

    public func info(_ message: @autoclosure () -> String,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
        log(message: message, level: .info, file: file, function: function, line: line)
    }

    public func warn(_ message: @autoclosure () -> String,
                     file: StaticString = #file,
                     function: StaticString = #function,
                     line: UInt = #line) {
        log(message: message, level: .warning, file: file, function: function, line: line)
    }


    public func error(_ message: @autoclosure () -> String,
                      file: StaticString = #file,
                      function: StaticString = #function,
                      line: UInt = #line) {
        log(message: message, level: .error, file: file, function: function, line: line)
    }

    private func log(message: () -> String,
                     level: Level,
                     file: StaticString,
                     function: StaticString,
                     line: UInt) {

        guard isEnabled, level >= minimumLevel else {
            return
        }

        let message = Message(timestamp: Date(),
                              message: message(),
                              level: level,
                              category: category,
                              file: file,
                              function: function,
                              line: line)
        parent.log(message)
    }
}
