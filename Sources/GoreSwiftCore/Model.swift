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
}

extension Model: XMLIndexerDeserializable {
    static func deserialize(_ node: XMLIndexer) throws -> Model {
        return try Model(
            entities: node["entity"].value()
        )
    }
}
