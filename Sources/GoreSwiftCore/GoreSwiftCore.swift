import Foundation
import Commander
import SWXMLHash

public struct CoreSwiftCore {
    public static func run(input: URL, output: URL) throws {
        guard let xmlString = try? String(contentsOf: input) else {
            throw ArgumentError.unusedArgument("input")
        }
        let xml = SWXMLHash.parse(xmlString)
        let model = try Model.deserialize(xml["model"])
        for entity in model.entities {
            print(entity)
        }
    }
}
