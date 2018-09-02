//
//  Model.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/1.
//

import Foundation
import SWXMLHash

struct Model {
    let entities: [Entity]
    static var entities = Set<Entity>()
}

extension Model: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Model {
        let model = try Model(entities: node["entity"].value())
        Model.entities = Set<Entity>(model.entities)
        return model
    }
}
