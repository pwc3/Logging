//
//  File.swift
//  
//
//  Created by Paul Calnan on 5/1/20.
//

import Foundation

public protocol FileDestination: AnyObject, Destination {

    var maximumFileSize: UInt64 { get set }

    var rollingFrequency: TimeInterval { get set }

    var maximumNumberOfLogFiles: UInt { get set }

    var logFilesDiskQuota: UInt64 { get set }

    var logsDirectory: String { get }

    var logFilePaths: [String] { get }

    func rollLogFile()
}
