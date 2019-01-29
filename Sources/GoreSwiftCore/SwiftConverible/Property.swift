//
//  Property.swift
//  GoreSwiftCore
//
//  Created by didi on 2019/1/25.
//

import Foundation


struct Property: SwiftCodeConverible, Comment {
    let comments: [String]
    fileprivate let accessLevel: AccessLevel
    fileprivate let `static`: Bool
    fileprivate let variable: Bool
    fileprivate let name: String
    fileprivate let value: String?
    fileprivate let type: String?
    fileprivate let extraModifier: [String]

    init(comments: [String] = [],
         accessLevel: AccessLevel = .internal,
         static: Bool = false,
         variable: Bool = false,
         name: String,
         value: String? = nil,
         type: String? = nil,
         extraModifier: [String] = []) {
        self.comments = comments
        self.accessLevel = accessLevel
        self.static = `static`
        self.variable = variable
        self.name = name
        self.value = value
        self.type = type
        self.extraModifier = extraModifier
    }

    var swiftCode: String {
        let extraModifierString = extraModifier.map { "\($0) " }.joined(separator: "")
        let staticString = `static` ? "static " : ""
        let letOrVarString = variable ? "var " : "let "
        let typeString  = type.map { ": \($0)" } ?? ""
        let valueString = value.map { " = \($0)" } ?? ""

        return commentsString
            .appending(extraModifierString)
            .appending(accessLevel.swiftCode)
            .appending(staticString)
            .appending(letOrVarString)
            .appending(name)
            .appending(typeString)
            .appending(valueString)
    }
}
