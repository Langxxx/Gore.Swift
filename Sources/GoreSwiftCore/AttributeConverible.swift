//
//  AttributeConverible.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/1.
//

import Foundation


protocol AttributeConverible {
    var attributeSwiftCode: String { get }
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
