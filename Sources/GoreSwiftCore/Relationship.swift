//
//  Relationship.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/1.
//

import Foundation
import SWXMLHash

struct Relationship {
    let name: String
    let optional: Bool
    let toMany: Bool
    let destinationEntityName: String
    let ordered: Bool
    let accessModifier = "public" //TODO

    init(name: String, optional: String?, toMany: String?, destinationEntityName: String, ordered: String?) {
        self.name = name
        self.optional = optional == "YES"
        self.toMany = toMany == "YES"
        self.destinationEntityName = destinationEntityName
        self.ordered = ordered == "YES"
    }
}

extension Relationship: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Relationship {
        return try Relationship(
            name: node.value(ofAttribute: "name"),
            optional: node.value(ofAttribute: "optional"),
            toMany: node.value(ofAttribute: "toMany"),
            destinationEntityName: node.value(ofAttribute: "destinationEntity"),
            ordered: node.value(ofAttribute: "ordered")
        )
    }
}

extension Relationship: AttributeConverible, AttributeKeyConverible {
    var attributeSwiftCode: String {
        let type = toMany ? (ordered ? "NSOrderedSet" : "NSSet") : destinationEntityName
        let optionalStr = (optional && !toMany) ? "?" : ""
        return "@NSManaged \(accessModifier) var \(name): \(type)\(optionalStr)"
    }
}

extension Relationship {
    var convenienceFunction: String? {
        guard toMany else { return nil }

    }
}
