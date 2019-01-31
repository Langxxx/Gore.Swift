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
    let uniquenessConstraints: [UniquenessConstraint]?
    let userInfo: [UserInfo]?
}

extension Entity: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Entity {
        return try Entity(
            name: node.value(ofAttribute: "name"),
            attributes: node["attribute"].value(),
            parrentName: node.value(ofAttribute: "parentEntity"),
            relationships: node["relationship"].value(),
            uniquenessConstraints: node["uniquenessConstraints"].value(),
            userInfo: node["userInfo"]["entry"].value()
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
        guard let uniquenessConstraints = uniquenessConstraints,
            parrent?.uniquenessConstraints == nil else {
                return nil
        }
        return uniquenessConstraints.flatMap { uniquenessConstraint in
            return fetchOrCreateFunctions(uniquenessConstraint: uniquenessConstraint) +
                fetchFunctions(uniquenessConstraint: uniquenessConstraint) +
                [_fetchOrCreateFunction(uniquenessConstraint: uniquenessConstraint)]
        }
    }

    private func fetchOrCreateFunctions(uniquenessConstraint: UniquenessConstraint) -> [Function] {
        guard case let .single(uniquenessConstraint) = uniquenessConstraint else {
            //TODO
            return []
        }
        let uniquenessConstraintParameter = Parameter(name: uniquenessConstraint, type: "String")

        let one = Function(
            accessModifier: .public,
            isClass: true,
            name: "fetchOrCreate",
            parameters: [contextParameter, uniquenessConstraintParameter],
            returnType: "Self",
            statements: [
                "var create: Bool = false",
                "return _fetchOrCreate(id: id, create: &create, in: context)"
            ])
        let two = Function(
            accessModifier: .public,
            isClass: true,
            name: "fetchOrCreate",
            parameters: [
                contextParameter,
                Parameter(name: "create", type: "Bool", isInout: true),
                uniquenessConstraintParameter,
            ],
            returnType: "Self",
            statements: ["return _fetchOrCreate(id: id, create: &create, in: context)"])
        return [one, two]
    }

    private func fetchFunctions(uniquenessConstraint: UniquenessConstraint) -> [Function] {
        guard case let .single(uniquenessConstraint) = uniquenessConstraint else {
            //TODO
            return []
        }
        let uniquenessConstraintParameter = Parameter(name: uniquenessConstraint, type: "String")

        let one = Function(
            accessModifier: .public,
            isClass: true,
            name: "fetch",
            parameters: [contextParameter, uniquenessConstraintParameter],
            returnType: "Self?",
            statements: ["return _fetch(\(uniquenessConstraint): \(uniquenessConstraint), in: context)"])
        let two = Function(
            accessModifier: .private,
            isClass: true,
            name: "_fetch<T: \(name)>",
            parameters: [contextParameter, uniquenessConstraintParameter],
            returnType: "T?",
            statements: ["return T.findOrFetch(in: context, predicate: Query.equal(\"\(uniquenessConstraint)\", \(uniquenessConstraint))"])
        return [one, two]
    }

    private func _fetchOrCreateFunction(uniquenessConstraint: UniquenessConstraint) -> Function {
        let guardBlock = Guard(
            conditions: ["let result = T.findOrFetch(in: context, predicate: Query.equal(\"\(uniquenessConstraint)\", \(uniquenessConstraint))"],
            statements: [
                "let o = T.insertObject(in: context)",
                "o.\(uniquenessConstraint) = \(uniquenessConstraint)",
                "create = true",
                "return o"
            ])
        let uniquenessConstraintParameter = Parameter(name: "TODO", type: "String")
        return Function(
            accessModifier: .private,
            isClass: true,
            name: "_fetchOrCreate<T: \(name)>",
            parameters: [
                contextParameter,
                Parameter(name: "create", type: "Bool", isInout: true),
                uniquenessConstraintParameter,
            ],
            returnType: "t",
            statements: [
                guardBlock,
                "create = false",
                "return result"
            ])
    }

    private var contextParameter: Parameter {
        return Parameter(localName: "in", name: "context", type: "NSManagedObjectContext")
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
            discardableResult: true,
            accessModifier: .public,
            override: parrent?.uniquenessConstraintWithParrent() != nil,
            isClass: true,
            name: "updateOrCreate",
            parameters: [
                Parameter(localName: "from", name: "json", type: "JSONResponse?"),
                contextParameter,
                Parameter(name: "configration", type: "((\(name), Bool) -> ())?", defaultValue: "nil"),
            ],
            returnType: "\(name)?",
            statements: statements)
    }

    func uniquenessConstraintWithParrent() -> [UniquenessConstraint]? {
        guard let uniquenessConstraint = self.uniquenessConstraints else {
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
