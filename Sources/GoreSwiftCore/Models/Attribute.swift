//
//  Attribute.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/1.
//

import Foundation
import SWXMLHash

struct Attribute {
    let name: String
    let defaultValue: String?
    let optional: Bool
    let type: String
    let accessModifier = "public" //TODO

    init(name: String, defaultValue: String?, optioanStr: String?, typeStr: String) {
        self.name = name
        self.optional = optioanStr == "YES"
        self.type = Attribute.typeTransform(with: typeStr)
        self.defaultValue = defaultValue.flatMap { typeStr == "String" ? "\"\($0)\"" : $0 }
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
            typeStr: node.value(ofAttribute: "attributeType")
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
            type: optional ? "\(type)?" : type,
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
