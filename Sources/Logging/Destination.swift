//
//  File.swift
//  
//
//  Created by Paul Calnan on 4/30/20.
//

import Foundation

public protocol Destination {

    associatedtype Category

    func log(_ message: Message<Category>)
}
