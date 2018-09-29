//
//  Generator.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/3.
//

import Foundation


protocol Generator {
    var extensionEntity: Extension { get }
    func generate() -> String
}

extension Generator {
    func generate() -> String {
        return extensionEntity.swiftCode
    }
}
