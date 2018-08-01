//
//  Entity.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/1.
//

import Foundation
import SWXMLHash

struct Entity {
    let name: String
    let attributes: [Attribute]
    let parrentName: String?
}

extension Entity: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Entity {
        return try Entity(
            name: node.value(ofAttribute: "name"),
            attributes: node["attribute"].value(),
            parrentName: node.value(ofAttribute: "parentEntity")
        )
    }
}

extension Entity: AttributeConverible, AttributeKeyConverible {
    var attributeKeySwiftCode: String {
        return attributes.map  { $0.attributeKeySwiftCode }
            .joined(separator: "\n")
    }

    var attributeSwiftCode: String {
        return attributes.map { $0.attributeSwiftCode }
            .joined(separator: "\n")
    }
}

extension Entity {
    var swiftCode: String {
        var section = [String]()
        section.append("extension \(name) {\n" + attributeSwiftCode.indent() + "\n}")
        section.append("extension \(name) {\n" + attributeKeySwiftCode.indent() + "\n}")
        return section.joined(separator: "\n\n")
    }
}
