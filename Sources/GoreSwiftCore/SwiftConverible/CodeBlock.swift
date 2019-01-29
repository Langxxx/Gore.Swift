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
        let str = statements.map { $0.swiftCode }
            .joined(separator: "\n")
            .indent()
        return "{\n\(str)\n}"
    }
}


protocol Comment {
    var comments: [String] { get }
}

extension Comment {
    var commentsString: String {
        return comments.map { "// \($0)\n" }.joined(separator: "")
    }
}
