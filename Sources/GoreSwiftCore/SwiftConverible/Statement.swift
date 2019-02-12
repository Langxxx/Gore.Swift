//
//  Statement.swift
//  GoreSwiftCore
//
//  Created by didi on 2019/1/29.
//

import Foundation

struct Statement: SwiftCodeConverible, Comment {
    let comments: [String]
    let str: SwiftCodeConverible

    init(_ str: SwiftCodeConverible, comments: [String] = []) {
        self.comments = comments
        self.str = str
    }

    var swiftCode: String {
        return "\(commentsString)\(str.swiftCode)"
    }
}

extension Statement {
    static func `return`(_ str: SwiftCodeConverible, comments: [String] = []) -> Statement {
        return Statement("return \(str.swiftCode)", comments: comments)
    }
    static func empty() -> Statement {
        return  Statement("", comments: [])
    }
    static func parseJSON(with jsonKey: String) -> Statement {
        guard jsonKey.contains(".") else {
            return Statement("json[\"\(jsonKey)\"]")
        }

        return Statement("(json as AnyObject).value(forKeyPath: \"\(jsonKey)\")")
    }
    static func divider(comments: [String] = []) -> Statement {
        return Statement("///////////////////////////////////////////////////////////////////////////////", comments: comments)
    }
}
