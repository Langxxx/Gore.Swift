//
//  Function.swift
//  Commander
//
//  Created by didi on 2018/9/2.
//

import Foundation

struct Function: CodeBlock {
    let comments: [String]
    let signature: String
    let statements: [SwiftCodeConverible]
}


extension Function: SwiftCodeConverible, Comment {
    var swiftCode: String {
        return "\(commentsString)\(signature) \(codeBlock)"
    }
}
