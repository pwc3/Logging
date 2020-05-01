//
//  File.swift
//  
//
//  Created by Paul Calnan on 4/30/20.
//

import Foundation

public struct Message<Category> {

    public var timestamp: Date

    public var message: String

    public var level: Level

    public var category: Category

    public var file: StaticString

    public var function: StaticString

    public var line: UInt
}
