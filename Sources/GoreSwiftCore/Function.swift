//
//  Function.swift
//  Commander
//
//  Created by didi on 2018/9/2.
//

import Foundation

struct Function {
    let comments: [String]
    let signature: String
    let body: String
}


extension Function {
    var swiftCode: String {
        let commentsString = comments.map { "/// \($0)\n" }.joined(separator: "")
        return "\(commentsString)\(signature) {\n\(body.indent())\n}"
    }
}
