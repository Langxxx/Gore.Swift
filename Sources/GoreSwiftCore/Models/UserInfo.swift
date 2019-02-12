//
//  UserInfo.swift
//  Commander
//
//  Created by didi on 2019/1/30.
//

import Foundation
import SWXMLHash

enum UserInfo {
    case jsonTransformer(String)
    case jsonKey(String)
    case forceUnwrap(Bool)
    case jsonIgnore(Bool)

    case unknown(String)
}

extension UserInfo: XMLElementDeserializable {
    static func deserialize(_ element: SWXMLHash.XMLElement) throws -> UserInfo {
        let key: String = try element.value(ofAttribute: "key")
        let value: String = try element.value(ofAttribute: "value")
        switch key {
        case "json_transformer":
            return .jsonTransformer(value)
        case "json_key":
            return .jsonKey(value)
        case "force_unwrap":
            return .forceUnwrap(value == "1")
        case "json_ignore":
            return .jsonIgnore(value == "1")
        default:
            print("undefined user info: \(key): \(value)")
            return .unknown(key)
        }
    }
}

@dynamicMemberLookup
protocol UserInfoProtocol {
    var userInfo: [UserInfo]? { get }
}
extension UserInfoProtocol {
    subscript(dynamicMember member: String) -> String? {
        guard let userInfo = self.userInfo else {
            return nil
        }

        for info in userInfo {
            switch (info, member) {
            case (let .jsonKey(key), "jsonKey"):
                return key
            case (let .jsonTransformer(key), "jsonTransformer"):
                return key
            default:
                return nil
            }
        }
        print("Can not find \(member)")
        return nil
    }
}
