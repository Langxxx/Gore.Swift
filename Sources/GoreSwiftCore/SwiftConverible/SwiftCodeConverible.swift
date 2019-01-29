//
//  SwiftCodeConverible.swift
//  Commander
//
//  Created by didi on 2018/9/14.
//

import Foundation

protocol SwiftCodeConverible {
    var swiftCode: String { get }
}

extension String: SwiftCodeConverible {
    var swiftCode: String {
        return self
    }
}
