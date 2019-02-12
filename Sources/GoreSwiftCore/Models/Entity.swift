//
//  Entity.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/1.
//

import Foundation
import SWXMLHash

@dynamicMemberLookup
struct Entity {
    let name: String
    let attributes: [Attribute]
    let parrentName: String?

    let relationships: [Relationship]?
    let uniquenessConstraints: [UniquenessConstraint]?
    let userInfo: [UserInfo]?

    subscript(dynamicMember attribute: String) -> Attribute? {
        return attributes.first { $0.name == attribute }
    }
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
        let one = Function(
            accessModifier: .public,
            isClass: true,
            name: "fetchOrCreate",
            parameters: uniquenessConstraint.asFormalParameter(with: self) + [contextParameter],
            returnType: "Self",
            statements: [
                "var create: Bool = false",
                "return _fetchOrCreate(\(uniquenessConstraint.asActualParameter()), create: &create, in: context)"
            ])
        let two = Function(
            accessModifier: .public,
            isClass: true,
            name: "fetchOrCreate",
            parameters: uniquenessConstraint.asFormalParameter(with: self) +  [
                Parameter(name: "create", type: "Bool", isInout: true),
                contextParameter
            ],
            returnType: "Self",
            statements: ["return _fetchOrCreate(\(uniquenessConstraint.asActualParameter()), create: &create, in: context)"])
        return [one, two]
    }

    private func fetchFunctions(uniquenessConstraint: UniquenessConstraint) -> [Function] {

        let one = Function(
            accessModifier: .public,
            isClass: true,
            name: "fetch",
            parameters: uniquenessConstraint.asFormalParameter(with: self) + [contextParameter],
            returnType: "Self?",
            statements: ["return _fetch(\(uniquenessConstraint.asActualParameter()), in: context)"])
        let two = Function(
            accessModifier: .private,
            isClass: true,
            name: "_fetch<T: \(name)>",
            parameters: uniquenessConstraint.asFormalParameter(with: self) + [contextParameter],
            returnType: "T?",
            statements: ["return T.findOrFetch(in: context, predicate: \(uniquenessConstraint.predicateString))"])
        return [one, two]
    }

    private func _fetchOrCreateFunction(uniquenessConstraint: UniquenessConstraint) -> Function {
        let guardBlock = Guard(
            conditions: ["let result = T.findOrFetch(in: context, predicate: \(uniquenessConstraint.predicateString))"],
            statements: [
                "let o = T.insertObject(in: context)",
                uniquenessConstraint.constraints.map { "o.\($0) = \($0)" }.joined(separator: "\n"),
                "create = true",
                "return o"
            ])
        let uniquenessConstraintParameter = Parameter(name: "TODO", type: "String")
        return Function(
            accessModifier: .private,
            isClass: true,
            name: "_fetchOrCreate<T: \(name)>",
            parameters: [
                Parameter(name: "create", type: "Bool", isInout: true),
                uniquenessConstraintParameter,
                contextParameter
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
        return _updateOrCreateFunction() + [_createFunction()]
    }

    private func _updateOrCreateFunction() -> [Function] {
        func ___updateOrCreateFunction(with constraint: UniquenessConstraint?) -> Function {
            var statements: [SwiftCodeConverible] = []
            let jsonValid = Guard(
                conditions: ["let json = json"],
                statements: [Statement.return("nil")])
            statements.append(jsonValid)
            statements.append(Statement.empty())

            if let constraint = constraint {
                let attributes = constraint.constraints
                    .compactMap { return self[dynamicMember: $0] }
                    .map { $0.jsonStatement }

                let ifID = If(
                    conditions: attributes + [
                        "let obj = \(name).fetch(\(constraint.asActualParameter()), in: context)"
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
                    Parameter(name: "configration", type: "((\(name), Bool) -> ())?", defaultValue: "nil")
                ],
                returnType: "\(name)?",
                statements: statements)
        }

        return uniquenessConstraints?.map(___updateOrCreateFunction(with:)) ?? [___updateOrCreateFunction(with: nil)]
    }

    func uniquenessConstraintWithParrent() -> [UniquenessConstraint]? {
        guard let uniquenessConstraint = self.uniquenessConstraints else {
            return parrent?.uniquenessConstraintWithParrent()
        }
        return uniquenessConstraint
    }

    private func _createFunction() -> Function {
        let jsonValid = Guard(
            conditions: ["let json = json"],
            statements: [Statement.return("nil")])

        var statements: [SwiftCodeConverible] = [jsonValid]

        statements.append(Statement.empty())
        statements.append(Statement.divider())
        statements.append(Statement("// check attributes if need"))
        let attributesString = attributes.map { attribute -> SwiftCodeConverible in
            let jsonStatement = attribute.jsonStatement
            guard !attribute.optional else {
                return jsonStatement
            }

            guard attribute.defaultValue == nil else {
                return jsonStatement
            }

            return If(
                conditions: [jsonStatement],
                statements: [
                    "log.warning(\"missing '\(attribute.name)'\")",
                    Statement.return("nil")
                ])
        }
        statements.append(contentsOf: attributesString)
        statements.append(Statement.divider())
        statements.append(Statement.empty())

        statements.append(Statement.divider())
        statements.append(Statement("// check relationships if need"))
        let relationshipString = relationships?.compactMap { $0.jsonStatement } ?? []
        statements.append(contentsOf: relationshipString)
        statements.append(Statement.divider())
        statements.append(Statement.empty())

        statements.append(Statement.divider())
        statements.append(Statement("let obj = \(name).insertObject(in: context)", comments: ["insert to context (already try fetched above if needed)"]))
        statements.append(Statement.empty())

        let assignAttributes = Statement(attributes.map { "obj.\($0.name) = \($0.name)" }.joined(separator: "\n"),
                                         comments: ["assign attributes"])
        statements.append(assignAttributes)
        if let relationships = relationships {
            let assignRelationship = Statement(relationships.filter { $0.jsonKey != nil }.map { "obj.\($0.name) = \($0.name)" }.joined(separator: "\n"),
                                               comments: ["assign relationship"])
            statements.append(assignRelationship)
        }

        statements.append(Statement.empty())
        statements.append(Statement("configration?(obj)"))
        statements.append(Statement.empty())
        statements.append(Statement.return("obj"))
        
        return Function(
            discardableResult: true,
            accessModifier: .public,
            override: parrent != nil,
            isClass: true,
            name: "create",
            parameters: [
                Parameter(localName: "from", name: "json", type: "JSONResponse?"),
                contextParameter,
                Parameter(name: "configration", type: "((\(name), Bool) -> ())?", defaultValue: "nil")
            ],
            returnType: name,
            statements: statements)
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
