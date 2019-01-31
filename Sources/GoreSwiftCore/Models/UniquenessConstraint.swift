//
//  UniquenessConstraint.swift
//  Commander
//
//  Created by didi on 2019/1/30.
//

import Foundation
import SWXMLHash

enum UniquenessConstraint {
    case single(String)
    case composite([String])
}


extension UniquenessConstraint: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> UniquenessConstraint {
        let elements = node["uniquenessConstraint"]["constraint"].all
        let constraints: [String] = try elements
            .map { try $0.value(ofAttribute: "value") }

        switch constraints.count {
        case 1:
            return .single(constraints[0])
        case 1...:
            return .composite(constraints)
        default:
            throw XMLDeserializationError.nodeHasNoValue
        }
    }

}

//extension Array: XMLElementDeserializable where Element == UniquenessConstraint {
//    private static func deserialize(_ element: SWXMLHash.XMLElement) throws -> UniquenessConstraint {
//         throw XMLDeserializationError.nodeHasNoValue
//    }
//}
