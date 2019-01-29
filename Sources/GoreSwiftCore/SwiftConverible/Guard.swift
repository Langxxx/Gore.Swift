//
//  Guard.swift
//  GoreSwiftCore
//
//  Created by didi on 2019/1/25.
//

import Foundation

struct Guard: CodeBlock, SwiftCodeConverible {

    let conditions: [SwiftCodeConverible]
    let statements: [SwiftCodeConverible]

    var swiftCode: String {
        let base = "guard " + conditions.map { $0.swiftCode }.joined(separator: ",\n") + " else "
        return base + codeBlock
    }
}
