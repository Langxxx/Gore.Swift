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
    var attributesGenerator: AttributeGenerator {
        return AttributeGenerator(entity: self)
    }
    var attributesKeyGenerator: AttributeKeyGenerator {
        return AttributeKeyGenerator(entity: self)
    }
    var convenienceFunctionGenerator: ConvenienceFucntionGenerator {
        return ConvenienceFucntionGenerator(entity: self)
    }
}

extension Entity {
    var swiftCode: String {
        let all: [Generator] = [attributesGenerator, attributesKeyGenerator, convenienceFunctionGenerator]
        return  all.map { $0.generate() }.joined(separator: "\n\n")
    }
}

extension Entity: Hashable {
    static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.name == rhs.name
    }

    var hashValue: Int {
        return name.hashValue
    }
}
