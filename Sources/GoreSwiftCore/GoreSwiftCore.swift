import Foundation
import Commander
import SWXMLHash

public struct CoreSwiftCore {
    public static func run(input: URL, outputDir: URL) throws {
        guard let xmlString = try? String(contentsOf: input) else {
            throw ArgumentError.unusedArgument("input")
        }
        let xml = SWXMLHash.parse(xmlString)
        let model = try Model.deserialize(xml["model"])
        for entity in model.entities {
            let outputFile = outputDir.appendingPathComponent("\(entity.name)+CoreDataProperties.swift", isDirectory: false)
            do {
                try entity.swiftCode.write(to: outputFile, atomically: true, encoding: .utf8)
                print("generated \(outputFile.path)")
            } catch {
                print("\(error)")
            }
        }

    }
}
