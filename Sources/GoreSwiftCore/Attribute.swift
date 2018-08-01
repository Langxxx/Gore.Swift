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
    let optional: String?
    let type: String
}


extension Attribute: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Attribute {
        return try Attribute(
            name: node.value(ofAttribute: "name"),
            defaultValue: node.value(ofAttribute: "defaultValueString"),
            optional: node.value(ofAttribute: "optional"),
            type: node.value(ofAttribute: "attributeType")
        )
    }
}
