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
    fileprivate let `else`: Else?

    init(conditions: [SwiftCodeConverible], statements: [SwiftCodeConverible]) {
        self.init(conditions: conditions, statements: statements, else: nil)
    }

    fileprivate init(conditions: [SwiftCodeConverible], statements: [SwiftCodeConverible], else: Else?) {
        self.conditions = conditions
        self.statements = statements
        self.else = `else`
    }

    var swiftCode: String {
        let base = "if " + conditions.map { $0.swiftCode }.joined(separator: ",\n\("".indent())") + " "
        let elseString = self.else?.codeBlock

        return base + codeBlock + (elseString.map { " else \($0)" } ?? "")
    }
}

private struct Else: CodeBlock {
    let statements: [SwiftCodeConverible]
}

extension If {
    func `else`(statements: [SwiftCodeConverible]) -> If {
        return .init(conditions: conditions, statements: self.statements, else: Else(statements: statements))
    }
}
