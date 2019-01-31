//
//  Function.swift
//  Commander
//
//  Created by didi on 2018/9/2.
//

import Foundation

struct Function: CodeBlock {
    let comments: [String]
    let accessModifier: AccessLevel
    let isStatic: Bool
    let isClass: Bool
    let name: String
    let parameters: [Parameter]
    let returnType: String?
    let statements: [SwiftCodeConverible]
    let discardableResult: Bool
    let override: Bool

    init(comments: [String] = [],
         discardableResult: Bool = false,
         accessModifier: AccessLevel = .internal,
         override: Bool = false,
         isStatic: Bool = false,
         isClass: Bool = false,
         name: String,
         parameters: [Parameter],
         returnType: String? = nil,
         statements: [SwiftCodeConverible]) {
        self.comments = comments
        self.accessModifier = accessModifier
        self.isStatic = isStatic
        self.isClass = isClass
        self.name = name
        self.parameters = parameters
        self.returnType = returnType
        self.statements = statements
        self.discardableResult = discardableResult
        self.override = override
    }
}


extension Function: SwiftCodeConverible, Comment {
    var swiftCode: String {
        var isStaticOrClass = isStatic ? "static " : ""
        if isClass {
            isStaticOrClass = "class "
        }
        let parametersString = parameters
            .map { $0.swiftCode }
            .joined(separator: ", ")
        let returnTypeString = returnType.map { " -> \($0)" } ?? ""
        let discardableResultString = discardableResult ? "@discardableResult\n" : ""
        let overrideString = override ? "override " : ""
        let accessModifierString = accessModifier.swiftCode.isEmpty ? "" : "\(accessModifier.swiftCode)"

        return "\(commentsString)\(discardableResultString)\(accessModifierString)\(overrideString)\(isStaticOrClass)func \(name)(\(parametersString))\(returnTypeString) \(codeBlock)"
    }
}


struct Parameter: SwiftCodeConverible {
    let name: String
    let localName: String?
    let type: String
    let defaultValue: String?
    let isInout: Bool

    init(localName: String? = "",
         name: String,
         type: String,
         defaultValue: String? = nil,
         isInout: Bool = false) {
        self.name = name
        self.localName = localName
        self.type = type
        self.defaultValue = defaultValue
        self.isInout = isInout
    }

    var swiftCode: String {
        let defaultValueString = defaultValue.map { " = \($0)" } ?? ""
        let isInoutString = isInout ? "inout " : ""
        let localNameString = localName.map { $0.isEmpty ? "" : "\($0) " } ?? "_ "

        return "\(localNameString)\(name): \(isInoutString)\(type)\(defaultValueString)"
    }
}
