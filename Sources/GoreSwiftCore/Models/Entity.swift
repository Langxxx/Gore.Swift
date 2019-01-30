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
    var swiftCode: String {
        let all: [SwiftCodeConverible?] = [
            attributeExtension,
            attributeKeyExtension,
            relationshipConvenienceFunctionExtension,
            fetchOrCreateFunctionExtension,
            updateOrCreateFunctionExtension
        ]
        return  all.compactMap { $0?.swiftCode }.joined(separator: "\n\n")
    }
}

extension Entity {
    var attributeExtension: Extension {
        let attributes: [SwiftCodeConverible] = ["// attributes"] + self.attributes.map { $0.property }
        let relationships: [SwiftCodeConverible] = ["// relationships"] + (self.relationships?.map { $0.property } ?? [])
        return Extension(
            name: name,
            statements: attributes + [""] + relationships)
    }

    var attributeKeyExtension: Extension {
        let attributes: [SwiftCodeConverible] = ["// attributes"] + self.attributes.map { $0.keyPathProperty }
        let relationships: [SwiftCodeConverible] = ["// relationships"] + (self.relationships?.map { $0.keyPathProperty } ?? [])
        return Extension(
            name: name,
            statements: attributes + [""] + relationships)
    }

    var relationshipConvenienceFunctionExtension: Extension {
        let functions = relationships?
            .compactMap { $0.convenienceFucntion }
            .flatMap { $0 }
        return Extension(
            comments: ["for to-many relationship convenience"],
            name: name,
            statements: functions ?? [])
    }

    var fetchOrCreateFunctionExtension: Extension? {
        guard let fetchFunction = self.fetchFunction else {
            return nil
        }
        return Extension(
            comments: [],
            name: name,
            statements: fetchFunction)
    }

    var updateOrCreateFunctionExtension: Extension {
        return Extension(
            comments: [],
            name: name,
            statements: updateOrCreateFunction)
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
        let one = Function(
            comments: [],
            signature: "public class func fetchOrCreate(\(uniquenessConstraint): String, in context: NSManagedObjectContext) -> Self",
            statements: [
                "var create: Bool = false",
                "return _fetchOrCreate(id: id, create: &create, in: context)"
            ])
        let two = Function(
            comments: [],
            signature: "public class func fetchOrCreate(\(uniquenessConstraint): String, create: inout Bool, in context: NSManagedObjectContext) -> Self",
            statements: ["return _fetchOrCreate(id: id, create: &create, in: context)"])
        return [one, two]
    }

    private func fetchFunctions(uniquenessConstraint: String) -> [Function] {
        let one = Function(
            comments: [],
            signature: "public class func fetch(\(uniquenessConstraint): String, in context: NSManagedObjectContext) -> Self?",
            statements: ["return _fetch(\(uniquenessConstraint): \(uniquenessConstraint), in: context)"])
        let two = Function(
            comments: [],
            signature: "private class func _fetch<T: \(name)>(\(uniquenessConstraint): String, in context: NSManagedObjectContext) -> T?",
            statements: ["return T.findOrFetch(in: context, predicate: Query.equal(\"\(uniquenessConstraint)\", \(uniquenessConstraint))"])
        return [one, two]
    }

    private func _fetchOrCreateFunction(uniquenessConstraint: String) -> Function {
        let guardBlock = Guard(
            conditions: ["let result = T.findOrFetch(in: context, predicate: Query.equal(\"\(uniquenessConstraint)\", \(uniquenessConstraint))"],
            statements: [
                "let o = T.insertObject(in: context)",
                "o.\(uniquenessConstraint) = \(uniquenessConstraint)",
                "create = true",
                "return o"
            ])
        return Function(
            comments: [],
            signature: "private class func _fetchOrCreate<T: \(name)>(\(uniquenessConstraint): String, create: inout Bool, in context: NSManagedObjectContext) -> T",
            statements: [
                guardBlock,
                "create = false",
                "return result"
            ])
    }
}

extension Entity {
    var updateOrCreateFunction: [Function] {
        return [_updateOrCreateFunction()]
    }

    private func _updateOrCreateFunction() -> Function {
        var statements: [SwiftCodeConverible] = []
        let jsonValid = Guard(
            conditions: ["let json = json"],
            statements: [Statement.return("nil")])
        statements.append(jsonValid)
        statements.append(Statement.empty())

        if let id = uniquenessConstraintWithParrent() {
            let ifID = If(
                conditions: [
                    "let id = json[\"\(id)\"] as? String",
                    "let obj = \(name).fetch(id: \(id), in: context)"
                ], statements: [
                    "obj.update(from: json)",
                    "configration?(obj, false)",
                    Statement.return("obj")
                ])
            statements.append(Statement(ifID, comments: ["use identifier attribute to fetch first, if already exsit, just update it"]))
        }
        let returnCreated = Statement.return("create(from: json, in: context) {\n\("configration?($0, true)".indent())\n}")
        statements.append(returnCreated)
        return Function(
            comments: [],
            signature: "@discardableResult\npublic \(parrent == nil ? "" : "override ")class func updateOrCreate(from json: JSONResponse?, in context: NSManagedObjectContext, configration: ((\(name), Bool) -> ())? = nil) -> \(name)?",
            statements: statements)
    }

    func uniquenessConstraintWithParrent() -> String? {
        guard let uniquenessConstraint = self.uniquenessConstraint else {
            return parrent?.uniquenessConstraintWithParrent()
        }
        return uniquenessConstraint
    }
    //TODO: 
//    private func _createFunction() -> Function {
//        let jsonValid = Guard(
//            conditions: ["let json = json"],
//            statements: [Statement.return("nil")])
//
//
//    }
}


extension Entity: Hashable {
    static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.name == rhs.name
    }

    var hashValue: Int {
        return name.hashValue
    }
}
