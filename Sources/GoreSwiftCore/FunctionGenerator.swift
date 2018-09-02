//
//  Function.swift
//  Commander
//
//  Created by didi on 2018/9/2.
//

import Foundation


protocol FunctionConverible {
    var signature: [String] { get }
    var body: [String] { get }
    var functionSwiftCode: String { get }
}

extension FunctionConverible {
    var functionSwiftCode: String {
        return zip(signature, body)
            .map { signature, body in return "\(signature) {\n\(body.indent())\n}" }
            .joined(separator: "\n")
    }
}

struct ConvenienceFucntionGenerator: Generator {
    let entity: Entity

    var body: String {
        let relationship = entity.relationships?.map { $0.functionSwiftCode }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
        return relationship ?? ""
    }
    func generate() -> String {
        return "extension \(entity.name) {\n" + body.indent() + "\n}"
    }

}

