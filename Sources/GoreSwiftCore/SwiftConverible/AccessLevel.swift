//
//  AccessLevel.swift
//  GoreSwiftCore
//
//  Created by didi on 2019/1/25.
//

import Foundation

public enum AccessLevel: String, SwiftCodeConverible {
    case `public`
    case `internal`
    case `fileprivate`
    case `private`

    var swiftCode: String {
        if self == .`internal` {
            return ""
        }

        return "\(self.rawValue) "
    }
}
