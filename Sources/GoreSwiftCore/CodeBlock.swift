//
//  CodeBlock.swift
//  Commander
//
//  Created by didi on 2018/9/14.
//

import Foundation

protocol CodeBlock {
    var statements: [SwiftCodeConverible] { get }
    var codeBlock: String { get }
}

extension CodeBlock {
    var codeBlock: String {
        return "{\n\(statements.map { $0.swiftCode }.joined(separator: "\n").indent())\n}"
    }
}


struct Extension: CodeBlock, SwiftCodeConverible {
    let statements: [SwiftCodeConverible]
    let entityName: String

    var swiftCode: String {
        return "extension \(entityName) \(codeBlock)"
    }
}

struct Guard: CodeBlock, SwiftCodeConverible {

    let conditions: [SwiftCodeConverible]
    let statements: [SwiftCodeConverible]

    var swiftCode: String {
        let base = "guard " + conditions.map { $0.swiftCode }.joined(separator: ",\n") + " else "
        return base + codeBlock
    }
}
