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

extension UniquenessConstraint {
    var constraints: [String] {
        switch self {
        case .single(let attribute):
            return [attribute]
        case .composite(let attributes):
            return attributes
        }
    }

    func asFormalParameter(with entity: Entity) -> [Parameter] {
        return constraints
            .compactMap { return entity[dynamicMember: $0] }
            .map { return Parameter(name: $0.name, type: $0.type) }
    }

    func asActualParameter() -> String {
        return constraints.map { "\($0): \($0)" }
            .joined(separator: ", ")
    }

    var predicateString: String {
        guard constraints.count > 1 else {
            return "Query.equal(\"\(constraints[0])\", \(constraints[0]))"
        }

        let predicate = constraints.map { "Query.equal(\"\($0)\", \($0))" }
            .joined(separator: ", ")
        return "NSCompoundPredicate(andPredicateWithSubpredicates: [\(predicate)].map { $0.predicate })"
    }
}
