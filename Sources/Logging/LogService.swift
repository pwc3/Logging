//
//  LogService.swift
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

import CocoaLumberjackSwift
import Foundation

@dynamicMemberLookup
public class LogService<Context> where Context: LogContext {
    
    public enum Destination: Hashable {
        
        case os(LogFormatter<Context>)
        
        case file(LogFormatter<Context>)
    }
    
    public enum Option: Hashable {
        
        case fileRollingFrequency(TimeInterval)
        
        case maximumNumberOfLogFiles(UInt)
    }
    
    public private(set) var osLogger: DDOSLogger?

    public private(set) var fileLogger: DDFileLogger?
    
    private let loggers: [Context: Logger<Context>]
    
    public init(destinations: Set<Destination> = [.os(LogFormatter<Context>(includeTimestamp: false))],
                options: Set<Option> = []) {
        
        for d in destinations {
            switch d {

            case .os(let formatter):
                let l = DDOSLogger.sharedInstance
                osLogger = l
                
                l.logFormatter = formatter
                DDLog.add(l)
                
            case .file(let formatter):
                let l = DDFileLogger()
                fileLogger = l
                
                l.logFormatter = formatter
                DDLog.add(l)
            }
        }
        
        for o in options {
            switch o {
            case .fileRollingFrequency(let interval):
                fileLogger?.rollingFrequency = interval
                
            case .maximumNumberOfLogFiles(let count):
                fileLogger?.logFileManager.maximumNumberOfLogFiles = count
            }
        }
        
        var loggers = [Context: Logger<Context>]()
        for c in Context.allCases {
            loggers[c] = Logger<Context>(context: c)
        }
        self.loggers = loggers
    }
    
    public func rollLogFile(completion: (() -> Void)? = nil) {
        fileLogger?.rollLogFile(withCompletion: completion)
    }
    
    public subscript(dynamicMember member: Context) -> Logger<Context> {
        get {
            guard let logger = loggers[member] else {
                fatalError("No logger named \(member) found")
            }
            
            return logger
        }
    }
    
    public func setMinimumLogLevel(_ level: LogLevel) {
        loggers.values.forEach {
            $0.minimumLogLevel = level
        }
    }
}
