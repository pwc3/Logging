//
//  File.swift
//  
//
//  Created by Paul Calnan on 5/1/20.
//

import Foundation

internal extension CaseIterable where Self.AllCases.Element: Equatable {

    static func at(index: Int) -> Self {
        return allCases[index as! Self.AllCases.Index]
    }

    var index: Int {
        return Self.allCases.firstIndex(of: self) as! Int
    }
}
