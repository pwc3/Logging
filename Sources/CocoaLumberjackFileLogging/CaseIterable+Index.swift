//
//  CaseIterable+Index.swift
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

import Foundation

/// This extension lets us find the index of an `CaseIterable` enum value. This is needed to convert between a `Context` enum and a `DDLogMessage` context integer.
///
/// There are two force-unwraps here enforcing the assumption that the index of a `CaseIterable` is an `Int`.
internal extension CaseIterable where Self.AllCases.Element: Equatable {

    /// Returns the enum value at the specified index.
    static func at(index: Int) -> Self {
        return allCases[index as! Self.AllCases.Index]
    }

    /// Returns the index of this enum value.
    var index: Int {
        return Self.allCases.firstIndex(of: self) as! Int
    }
}
