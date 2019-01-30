//
//  UserInfo.swift
//  Commander
//
//  Created by didi on 2019/1/30.
//

import Foundation
import SWXMLHash

enum UserInfo {
    case JSONTransformer(String)
    case JSONKey(String)
    case forceUnwrap(Bool)
    case JSONIgnore(Bool)

    case unknown(String)
}

extension UserInfo: XMLElementDeserializable {
    static func deserialize(_ element: SWXMLHash.XMLElement) throws -> UserInfo {
        let key: String = try element.value(ofAttribute: "key")
        let value: String = try element.value(ofAttribute: "value")
        switch key {
        case "json_transformer":
            return .JSONTransformer(value)
        case "json_key":
            return .JSONKey(value)
        case "force_unwrap":
            return .forceUnwrap(value == "1")
        case "json_ignore":
            return .JSONIgnore(value == "1")
        default:
            print("undefined user info: \(key): \(value)")
            return .unknown(key)
        }
    }
}
