# Logging

This package provides basic logging functionality that can route log messages to multiple destinations. By default, the library supports logging to `NSLog` and to `os_log`. An add-on library contained in this package allows for logging to files. Additional logging destinations can be added by developers using the protocols provided in the library.

## Libraries

There are three libraries contained in this package:

- `Logging`: The core Logging library.
- `CocoaLumberjackFileLogging`: An optional add-on library enabling file logging backed by the [CocoaLumberjack][cocoa-lumberjack] package.
- `LogFileViewer`: An optional library providing a UIKit-based log file viewer for iOS.

## Installation

Installation is done via the Swift Package Manager. Add this repo to your `Package.swift` or via _File_ > _Add Package Dependency..._ in Xcode.

### In `Package.swift`

Add the following to your package's `dependencies`:

```swift
let package = Package(
    // ...
    dependencies: [
        // ...
        .package(url: "https://github.com/pwc3/Logging", .branch("master")),
    ],
```

Then add the one or more of the following `.product` values to the `dependencies` in your `.target`:

```swift
    targets: [
        .target(
            // ...
            dependencies: [
                // ...

                // Required: Core Logging library
                .product(name: "Logging", package: "Logging"),

                // Optional: file logging via CocoaLumberjack
                .product(name: "CocoaLumberjackFileLogging", package: "Logging"),

                // Optional: iOS log file viewer.
                .product(name: "LogFileViewer", pacakge: "Logging"),
            ]),
```

### In Xcode

Select _File_ > _Add Package Dependency..._ in Xcode. Add this repo's URL when prompted. Select the libraries you want to add.

## Basic Logging

Your application should create a single instance of the `LoggingService` class. Usually this a global variable called `log`.

You must add at least one `Destination` to the `LoggingService` instance. Without this, no log messages will actually appear.

The core `Logging` library provides two destinations:

- `NSLogDestination` which records log messages using the `NSLog()` function.
- `OSLogDestination` which records log messages using Apple's new `os_log()` function.

A protocol called `FileDestination` is provided to support file logging. No implementation of this is provided in the core `Logging` library. An implementation based on the [CocoaLumberjack][cocoa-lumberjack] library is provided in the `CocoaLumberjackFileLogging` library contained in this package. This is kept in a separate package so that using the core library does not impose any additional library dependencies.

In the simplest case, you would just add a single destination, say `NSLogDestination`. However, you can add additional destinations to enable you to log to a file, for example. Since `Destination` and `FileDestination` are protocols, you can define your own destinations to integrate with other logging packages.

The `LoggingService` class has a generic type parameter. This corresponds to the log category. You need to provide this type as a String enum that is `CaseIterable`. Logging categories allow you to categorize your log messages. It's up to you to decide what and how many categories you use. The choice is largely dependent upon the application. For example, you may have an `api` category for remote API calls, a `ui` category for user-interface code, an `app` category for application-lifecycle messages. You can then control the verbosity (log level) of each category independently. The log output is formatted in such a way that it is easy to filter specific categories, allowing you to focus on a specific category you are working on or troubleshooting.

### Setup

The basic setup of the logging system might look like this:

```swift
//
//  Log.swift
//

import Logging

enum Category: String, CaseIterable {
    case app
    case ui
}

let log: LoggingService<Category> = {
    let service = LoggingService<Category>()
    service.add(destination: NSLogDestination())
}()
```

After setting up the `LoggingService` instance, you can use it to write log messages. The syntax to do so looks like this:

```swift
log[.app].error("This is an error-level message")
log[.app].warn("This is a warning-level message")
log[.app].info("This is an info-level message")
log[.app].debug("This is a debug-level message")
log[.app].verbose("This is a verbose-level message")
```

The subscript is used to retrieve the `Logger` instance for the specified `Category`. Thus `log[.app]` retrieves the `Logger` for the `.app` category. You can also retrieve the logger by calling `LoggingService.logger(for:)` passing in the category value. Thus, `log[.app]` is equivalent to `log.logger(for: .app)`.

There are five log levels, which correspond to the logging functions called in the code snippet above. In increasing order of severity, they are:

- `verbose`
- `debug`
- `info`
- `warning`
- `error`

When you run the sample code above, something like the following will be printed to the console:

```
2020-05-13 22:19:30.802229-0400 xctest[15532:6682198] [error] [app] (SampleCode.swift:1) This is an error-level message
2020-05-13 22:19:30.802906-0400 xctest[15532:6682198] [warning] [app] (SampleCode.swift:2) This is a warning-level message
2020-05-13 22:19:30.803082-0400 xctest[15532:6682198] [info] [app] (SampleCode.swift:3) This is an info-level message
2020-05-13 22:19:30.803296-0400 xctest[15532:6682198] [debug] [app] (SampleCode.swift:4) This is a debug-level message
2020-05-13 22:19:30.803494-0400 xctest[15532:6682198] [verbose] [app] (SampleCode.swift:5) This is a verbose-level message
```

The log level is printed in the first set of square brackets. The category printed in the second set of square brackets. The file name and line number of the log statement is printed in parenthesis. Then follows the actual log message.

If you don't like the format of the log message, you can write your own `MessageFormatter` and pass it to the destination's initializer.

You can set the minimum log level for the entire service by calling `LoggingService.setMinimumLevel(_:)`. You can also set the minimum log level of an individual category by setting the `minimumLevel` property of that category's logger. For example:

```swift
// Set the minimum log level across all categories to `.warning`
log.setMinimumLevel(.warning)

// Override the minimum log level for the `.app` category, setting it to `.info`
log[.app].minimumLevel = .info
```

## File-Based Logging

Enabling file-based logging is similar to the basic setup described above:

```swift
//
//  Log.swift
//

import CocoaLumberjackFileLogging
import Logging

enum Category: String, CaseIterable {
    case app
    case ui
}

let log: LoggingService<Category> = {
    let service = LoggingService<Category>()
    service.add(destination: NSLogDestination())
    service.add(destination: CocoaLumberjackFileDestination())
}()
```

That's it. Everything else works as described above. The only difference is that log messages are sent to `NSLog` and to files managed by CocoaLumberjack.

## Log-File Viewing

It is sometimes useful to be able to view logs on-device when away from your computer. The `LogFileViewer` library included in this package makes this easy to do. In this example, we'll assume you have set up a global `log` variable as shown in the examples above.

```swift
import LogFileViewer
import UIKit

class MyViewController: UIViewController {

    func viewLogs() {
        // Find the FileDestination, if one exists.
        guard let dest = log.fileDestinations.first else {
            return
        }

        let vc = LogFileViewer(fileDestination: dest)
        present(vc, animated: true)
    }
}
```

Calling `LogFileViewer(fileDestination:)` creates a `UINavigationController` with a root view controller showing the list of log files currently available. This is useful when presenting the view modally.

You can also call `LogFileViewer(fileDestination:embedInNavigationController:)` passing `false` as the `embedInNavigationController` parameter. You can then push the returned `UIViewController` on your navigation controller. Note that the view controller _must_ be pushed on a `UINavigationController`, as one is used to navigate into the log files.

When viewing the list of log files, you can select one to open it and view its contents. There is an action button in the top-right allowing you to share the contents of the log file via a `UIActivityViewController` (share sheet).

Swiping on any log file in the list _except the first log file_ (which is the active file) provides the option to delete the file.

[cocoa-lumberjack]: https://github.com/CocoaLumberjack/CocoaLumberjack

