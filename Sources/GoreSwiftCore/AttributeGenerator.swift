//
//  AttributeGenerator.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/3.
//

import Foundation

protocol AttributeConverible {
    var attributeSwiftCode: String { get }
}

struct AttributeGenerator: Generator {
    let entity: Entity

    var body: String {
        let attributes = entity.attributes.map { $0.attributeSwiftCode }
            .reduce(into: "// attributes") { $0 = $0 + "\n" + $1 }
        let relationships =  entity.relationships?.map { $0.attributeSwiftCode }
            .reduce(into: "// relationship") { $0 = $0 + "\n" + $1 } ?? ""
        return [attributes, relationships].joined(separator: "\n\n")
    }
    func generate() -> String {
        return "extension \(entity.name) {\n" + body.indent() + "\n}"
    }
}

protocol AttributeKeyConverible {
    var accessModifier: String { get }
    var name: String { get }
    var attributeKeySwiftCode: String { get }
}

extension AttributeKeyConverible {
    var attributeKeySwiftCode: String {
        return "@nonobjc \(accessModifier) static let \(name) = \"\(name)\""
    }
}

struct AttributeKeyGenerator: Generator {
    let entity: Entity

    var body: String {
        let attributes = entity.attributes.map { $0.attributeSwiftCode }
            .reduce(into: "// attributes") { $0 = $0 + "\n" + $1 }
        let relationships =  entity.relationships?.map { $0.attributeSwiftCode }
            .reduce(into: "// relationship") { $0 = $0 + "\n" + $1 } ?? ""
        return [attributes, relationships].joined(separator: "\n\n")
    }

    func generate() -> String {
        return "extension \(entity.name) {\n" + body.indent() + "\n}"
    }
}
