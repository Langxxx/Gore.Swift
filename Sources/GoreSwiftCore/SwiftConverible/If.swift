//
//  If.swift
//  GoreSwiftCore
//
//  Created by didi on 2019/1/29.
//

import Foundation

struct If: CodeBlock, SwiftCodeConverible {
    let conditions: [SwiftCodeConverible]
    let statements: [SwiftCodeConverible]

    var swiftCode: String {
        let base = "if " + conditions.map { $0.swiftCode }.joined(separator: ",\n\("".indent())") + " "
        return base + codeBlock
    }
}
