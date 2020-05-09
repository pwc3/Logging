//
//  LogFileViewer.swift
//  LogFileViewer
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

import Logging
import UIKit

/// Creates a new log file viewer.
///
/// Note that the log file viewer must be contained in a navigation controller. One can be created automatically here, or you can embed it in your own:
/// - If `embedInNavigationController` is `true`, returns a `UINavigationController` suitable for modal presentation.
/// - If `embedInNavigationController` is `false`, the caller is responsible for embedding the returned view controller in a `UINavigationController`.
public func LogFileViewer<C>(fileDestination: AnyFileDestination<C>, embedInNavigationController: Bool = true) -> UIViewController {
    let vc = LogFileListViewController(fileDestination: fileDestination)
    return embedInNavigationController
        ? UINavigationController(rootViewController: vc)
        : vc
}
