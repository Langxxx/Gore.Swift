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

    let userInfo: [UserInfo]?

    init(name: String, optional: String?, toMany: String?, destinationEntityName: String, ordered: String?, userInfo: [UserInfo]?) {
        self.name = name
        self.optional = optional == "YES"
        self.toMany = toMany == "YES"
        self.destinationEntityName = destinationEntityName
        self.ordered = ordered == "YES"
        self.userInfo = userInfo
    }
}

extension Relationship: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Relationship {
        return try Relationship(
            name: node.value(ofAttribute: "name"),
            optional: node.value(ofAttribute: "optional"),
            toMany: node.value(ofAttribute: "toMany"),
            destinationEntityName: node.value(ofAttribute: "destinationEntity"),
            ordered: node.value(ofAttribute: "ordered"),
            userInfo: node["userInfo"]["entry"].value()
        )
    }
}

extension Relationship {
    var property: Property {
        return Property(
            comments: [],
            accessLevel: AccessLevel(rawValue: accessModifier) ?? .internal,
            static: false,
            variable: true,
            name: name,
            type: optional ? "\(type)?": type,
            extraModifier: ["@NSManaged"])
    }

    var keyPathProperty: Property {
        return Property(
            comments: [],
            accessLevel: AccessLevel(rawValue: accessModifier) ?? .internal,
            static: true,
            variable: false,
            name: name,
            value: "\"\(name)\"")
    }
}

fileprivate extension Relationship {
    var setDescription: String {
        return ordered ? "NSMutableOrderedSet" : "NSSet"
    }
    var type: String {
        guard toMany else {
            return destinationEntityName
        }
        return setDescription
    }
}

extension Relationship {
    var convenienceFucntion: [Function]? {
        if !toMany { return nil }
        let parameter = Parameter( name: "obj", type: destinationEntityName)

        let addRelationship = Function(
            comments: [],
            name: "add\(name.capitalized)Object",
            parameters: [parameter],
            statements: [
                "let mutable = \(name).mutableCopy() as! \(setDescription)",
                "mutable.add(obj)",
                "\(name) = mutable.copy() as! \(setDescription)",
            ])

        let removeRelationship = Function(
            comments: [],
            name: "remove\(name.capitalized)Objec",
            parameters: [parameter],
            statements: [
                "let mutable = \(name).mutableCopy() as! \(setDescription)",
                "mutable.remove(obj)",
                "\(name) = mutable.copy() as! \(setDescription)"
            ])
        return [addRelationship, removeRelationship]
    }
}


