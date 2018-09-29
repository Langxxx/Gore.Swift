//
//  Function.swift
//  Commander
//
//  Created by didi on 2018/9/2.
//

import Foundation


struct ConvenienceFucntionGenerator: Generator {
    let extensionEntity: Extension
    init(entity: Entity) {
        extensionEntity = Extension(statements: entity.relationships?.flatMap { $0.convenienceFucntion ?? [] } ?? [],
                                    entityName: entity.name)
    }
}

struct FetchOrCreateFunctionGenerator: Generator  {
    let extensionEntity: Extension

    init(entity: Entity) {
        extensionEntity = Extension(statements: entity.fetchFunction ?? [],
                                    entityName: entity.name)
    }
}

