//
//  File.swift
//  
//
//  Created by Paul Calnan on 4/30/20.
//

import Foundation

class AnyDestination<Category>: Destination {

    private let _log: (Message<Category>) -> Void

    init<D>(destination: D) where D: Destination, D.Category == Category {
        _log = destination.log
    }

    func log(_ message: Message<Category>) {
        _log(message)
    }
}
