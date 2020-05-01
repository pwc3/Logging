//
//  File.swift
//  
//
//  Created by Paul Calnan on 5/1/20.
//

import Foundation

class AnyFileDestination<Category>: AnyDestination<Category>, FileDestination {

    private let getMaximumFileSize: () -> UInt64
    private let setMaximumFileSize: (UInt64) -> Void

    private let getRollingFrequency: () -> TimeInterval
    private let setRollingFrequency: (TimeInterval) -> Void

    private let getMaximumNumberOfLogFiles: () -> UInt
    private let setMaximumNumberOfLogFiles: (UInt) -> Void

    private let getLogFilesDiskQuota: () -> UInt64
    private let setLogFilesDiskQuota: (UInt64) -> Void

    init<D>(fileDestination: D) where D: FileDestination, D.Category == Category {
        getMaximumFileSize = {
            fileDestination.maximumFileSize
        }

        setMaximumFileSize = {
            fileDestination.maximumFileSize = $0
        }

        getRollingFrequency = {
            fileDestination.rollingFrequency
        }

        setRollingFrequency = {
            fileDestination.rollingFrequency = $0
        }

        getMaximumNumberOfLogFiles = {
            fileDestination.maximumNumberOfLogFiles
        }

        setMaximumNumberOfLogFiles = {
            fileDestination.maximumNumberOfLogFiles = $0
        }

        getLogFilesDiskQuota = {
            fileDestination.logFilesDiskQuota
        }

        setLogFilesDiskQuota = {
            fileDestination.logFilesDiskQuota = $0
        }

        super.init(destination: fileDestination)
    }

    var maximumFileSize: UInt64 {
        get {
            return getMaximumFileSize()
        }

        set {
            setMaximumFileSize(newValue)
        }
    }

    var rollingFrequency: TimeInterval {
        get {
            return getRollingFrequency()
        }

        set {
            setRollingFrequency(newValue)
        }
    }

    var maximumNumberOfLogFiles: UInt {
        get {
            return getMaximumNumberOfLogFiles()
        }

        set {
            setMaximumNumberOfLogFiles(newValue)
        }
    }

    var logFilesDiskQuota: UInt64 {
        get {
            return getLogFilesDiskQuota()
        }

        set {
            setLogFilesDiskQuota(newValue)
        }
    }
}
