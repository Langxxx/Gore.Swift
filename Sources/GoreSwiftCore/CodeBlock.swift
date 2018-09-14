//
//  CodeBlock.swift
//  Commander
//
//  Created by didi on 2018/9/14.
//

import Foundation

protocol CodeBlock {
    var statements: [String] { get }
    var codeBlock: String { get }
}

extension CodeBlock {
    var codeBlock: String {
        return "{\n\(statements.joined(separator: "\n").indent())\n}"
    }
}


struct Extension: CodeBlock {
    let statements: [String]
    let entityName: String

    var swiftCode: String {
        return "extension \(entityName) \(codeBlock)"
    }
}

struct Guard: CodeBlock {

    let conditions: [String]
    let statements: [String]

    var swiftCode: String {
        let base = "guard " + conditions.joined(separator: ",\n") + "else "
        return base + codeBlock
    }
}
