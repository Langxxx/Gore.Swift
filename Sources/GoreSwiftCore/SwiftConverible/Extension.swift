//
//  Extension.swift
//  GoreSwiftCore
//
//  Created by didi on 2019/1/25.
//

import Foundation

struct Extension: CodeBlock, SwiftCodeConverible, Comment {
    let statements: [SwiftCodeConverible]
    let entityName: String
    let comments: [String]

    init(comments: [String] = [], name: String, statements: [SwiftCodeConverible]) {
        self.comments = comments
        self.entityName = name
        self.statements = statements
    }

    var swiftCode: String {
        return "\(commentsString)extension \(entityName) \(codeBlock)"
    }
}
