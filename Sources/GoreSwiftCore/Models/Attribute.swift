//
//  Attribute.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/1.
//

import Foundation
import SWXMLHash

struct Attribute: UserInfoProtocol {
    let name: String
    let defaultValue: String?
    let optional: Bool
    let type: String
    let accessModifier = "public" //TODO

    let userInfo: [UserInfo]?

    init(name: String, defaultValue: String?, optioanStr: String?, typeStr: String, userInfo: [UserInfo]?) {
        self.name = name
        let optional = optioanStr == "YES"
        let type = Attribute.typeTransform(with: typeStr)
        self.optional = optional
        self.type = optional ? "\(type)?" : type
        self.defaultValue = defaultValue.flatMap { typeStr == "String" ? "\"\($0)\"" : $0 }
        self.userInfo = userInfo
    }
}

private extension Attribute {
    static func typeTransform(with str: String) -> String {
        var result = str
        switch str {
        case "Binary":
            result = "Data"
        case "Boolean":
            result = "Bool"
        default: ()
        }
        if result.hasPrefix("Integer ") {
            result = str.replacingOccurrences(of: "Integer ", with: "Int")
        }
        return result
    }
}

extension Attribute: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Attribute {
        return try Attribute(
            name: node.value(ofAttribute: "name"),
            defaultValue: node.value(ofAttribute: "defaultValueString"),
            optioanStr: node.value(ofAttribute: "optional"),
            typeStr: node.value(ofAttribute: "attributeType"),
            userInfo: node["userInfo"]["entry"].value()
        )
    }
}

extension Attribute {
    var property: Property {
        return Property(
            comments: [],
            accessLevel: AccessLevel(rawValue: accessModifier) ?? .internal,
            static: false,
            variable: true,
            name: name,
            type: type,
            extraModifier: ["@NSManaged"])
    }

    var keyPathProperty: Property {
        return Property(
            comments: [],
            accessLevel: AccessLevel(rawValue: accessModifier) ?? .internal,
            static: true,
            variable: false,
            name: name,
            value: "\"\(name)\"")
    }
}

extension Attribute {
    var jsonStatement: Statement {
        let typeString = optional ? String(type.prefix(type.count - 1)) : type
        let defaultValueString = defaultValue.map { " ?? \($0)" } ?? ""
        let jsonKey = self.jsonKey ?? name
        let jsonTransformer = self.jsonTransformer.map {
            return "\($0)(\(Statement.parseJSON(with: jsonKey).swiftCode))"
            } ?? "\(Statement.parseJSON(with: jsonKey).swiftCode) as? \(typeString)\(defaultValueString)"

        return Statement("let \(name) = \(jsonTransformer)")
    }
}
