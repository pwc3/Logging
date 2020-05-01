//
//  LoggingTests.swift
//  LoggingTests
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

import XCTest
import Logging

enum Context: String, LogContext {

    case app
    
    case test
}

final class LoggingTests: XCTestCase {
    
    func testExample() {
        let log = LogService<Context>()
        log.setMinimumLogLevel(.warning)
        log[.test].minimumLogLevel = .info

        log[.app].error("Error message")
        log[.app].warn("Warn message")
        log[.app].info("Info message")
        log[.app].debug("Debug message")
        log[.app].verbose("Verbose message")
        
        log[.test].error("Error message")
        log[.test].warn("Warn message")
        log[.test].info("Info message")
        log[.test].debug("Debug message")
        log[.test].verbose("Verbose message")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
