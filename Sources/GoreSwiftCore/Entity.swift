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
    let uniquenessConstraint: String?
}

extension Entity: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Entity {
        return try Entity(
            name: node.value(ofAttribute: "name"),
            attributes: node["attribute"].value(),
            parrentName: node.value(ofAttribute: "parentEntity"),
            relationships: node["relationship"].value(),
            uniquenessConstraint: node["uniquenessConstraints"]["uniquenessConstraint"]["constraint"].value(ofAttribute: "value")
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
    var fetchOrCreateFunctionGenerator: FetchOrCreateFunctionGenerator {
        return FetchOrCreateFunctionGenerator(entity: self)
    }
}

extension Entity {
    var parrent: Entity? {
        guard let parrentName = parrentName else { return nil }
        return Model.entities.first { $0.name == parrentName }
    }
    var fetchFunction: [Function]? {
        guard let uniquenessConstraint = uniquenessConstraint,
            parrent?.uniquenessConstraint == nil else {
                return nil
        }
        return fetchOrCreateFunctions(uniquenessConstraint: uniquenessConstraint) +
            fetchFunctions(uniquenessConstraint: uniquenessConstraint) +
            [_fetchOrCreateFunction(uniquenessConstraint: uniquenessConstraint)]
    }

    private func fetchOrCreateFunctions(uniquenessConstraint: String) -> [Function] {
        let one = Function(comments: [],
                           signature: "public class func fetchOrCreate(\(uniquenessConstraint): String, in context: NSManagedObjectContext) -> Self",
                           body: "var create: Bool = false".nextLine("return _fetchOrCreate(id: id, create: &create, in: context)"))
        let two = Function(comments: [],
                           signature: "public class func fetchOrCreate(\(uniquenessConstraint): String, create: inout Bool, in context: NSManagedObjectContext) -> Self",
                           body: "return _fetchOrCreate(id: id, create: &create, in: context)")
        return [one, two]
    }

    private func fetchFunctions(uniquenessConstraint: String) -> [Function] {
        let one = Function(comments: [],
                           signature: "public class func fetch(\(uniquenessConstraint): String, in context: NSManagedObjectContext) -> Self?",
                           body: "return _fetch(\(uniquenessConstraint): \(uniquenessConstraint), in: context)")
        let two = Function(comments: [],
                           signature: "private class func _fetch<T: \(name)>(\(uniquenessConstraint): String, in context: NSManagedObjectContext) -> T?",
                           body: "return T.findOrFetch(in: context, predicate: Query.equal(\"\(uniquenessConstraint)\", \(uniquenessConstraint))")
        return [one, two]
    }

    private func _fetchOrCreateFunction(uniquenessConstraint: String) -> Function {
        let body = "guard let result = T.findOrFetch(in: context, predicate: Query.equal(\"\(uniquenessConstraint)\", \(uniquenessConstraint)) else {"
            .nextLine("let o = T.insertObject(in: context)".indent())
            .nextLine("o.\(uniquenessConstraint) = \(uniquenessConstraint)".indent())
            .nextLine("create = true".indent())
            .nextLine("return o".indent())
            .nextLine("}")
            .nextLine("")
            .nextLine("create = false")
            .nextLine("return result")
        return Function(comments: [],
                        signature: "private class func _fetchOrCreate<T: \(name)>(\(uniquenessConstraint): String, create: inout Bool, in context: NSManagedObjectContext) -> T",
                        body: body)
    }
}

extension Entity {
    var swiftCode: String {
        let all: [Generator] = [attributesGenerator, attributesKeyGenerator, convenienceFunctionGenerator, fetchOrCreateFunctionGenerator]
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
