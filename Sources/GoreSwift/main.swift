import Commander
import Foundation
import GoreSwiftCore

command (
    Argument<String>("input", description: "The xcdatamodeld file path"),
    Argument<String>("output", description: "Output directory for the 'XXXX+CoreDataProperties.swift' file.")
) { input, output in
    let inputURL = URL(fileURLWithPath: input, isDirectory: true)
    guard let xcdatamodeldName = inputURL.lastPathComponent.components(separatedBy: ".").first else {
        throw ArgumentError.unusedArgument("input")
    }
    let xmlPath = inputURL.appendingPathComponent("\(xcdatamodeldName).xcdatamodel/contents")
    guard FileManager.default.fileExists(atPath: xmlPath.path) else {
        throw ArgumentError.unusedArgument("input")
    }
    let outputURL = URL(fileURLWithPath: output, isDirectory: true)
    try CoreSwiftCore.run(input: xmlPath, outputDir: outputURL)
}.run()

