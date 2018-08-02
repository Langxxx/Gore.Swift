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

    let relationships: [Relationship]?
}

extension Entity: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Entity {
        return try Entity(
            name: node.value(ofAttribute: "name"),
            attributes: node["attribute"].value(),
            parrentName: node.value(ofAttribute: "parentEntity"),
            relationships: node["relationship"].value()
        )
    }
}

extension Entity {
    var attributeKeySecion: String {
        let attributes = self.attributes.map { $0.attributeKeySwiftCode }
            .reduce(into: "// attributes") { $0 = $0 + "\n" + $1 }
        let relationships =  self.relationships?.map { $0.attributeKeySwiftCode }
            .reduce(into: "// relationship") { $0 = $0 + "\n" + $1 } ?? ""
        return [attributes, relationships].joined(separator: "\n\n")
    }

    var attributeSection: String {
        let attributes = self.attributes.map { $0.attributeSwiftCode }
            .reduce(into: "// attributes") { $0 = $0 + "\n" + $1 }
        let relationships =  self.relationships?.map { $0.attributeSwiftCode }
            .reduce(into: "// relationship") { $0 = $0 + "\n" + $1 } ?? ""
        return [attributes, relationships].joined(separator: "\n\n")
    }
}

extension Entity {
    var swiftCode: String {
        var section = [String]()
        section.append("extension \(name) {\n" + attributeSection.indent() + "\n}")
        section.append("extension \(name) {\n" + attributeKeySecion.indent() + "\n}")
        return section.joined(separator: "\n\n")
    }
}
