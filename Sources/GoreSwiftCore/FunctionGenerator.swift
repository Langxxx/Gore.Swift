//
//  Function.swift
//  Commander
//
//  Created by didi on 2018/9/2.
//

import Foundation


struct ConvenienceFucntionGenerator: Generator {
    let entity: Entity

    var body: String {
        let relationship = entity.relationships?
            .compactMap { $0.convenienceFucntion }
            .flatMap { $0.map { $0.swiftCode } }
            .joined(separator: "\n")
        return relationship ?? ""
    }
    func generate() -> String {
        return "extension \(entity.name) {\n" + body.indent() + "\n}"
    }

}

struct FetchOrCreateFunctionGenerator: Generator  {
    let entity: Entity

    var body: String {
        guard let f = entity.fetchFunction else {
            return ""
        }
        return f.map { $0.swiftCode }
            .joined(separator: "\n\n")
    }
    func generate() -> String {
        return "extension \(entity.name) {\n" + body.indent() + "\n}"
    }
}

