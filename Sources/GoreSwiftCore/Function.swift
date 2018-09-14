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
    let statements: [String]
}


extension Function {
    var swiftCode: String {
        let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
        return "\(commentsString)\(signature) \(codeBlock)"
    }
}
