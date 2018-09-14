//
//  String+Extension.swift
//  GoreSwiftCore
//
//  Created by didi on 2018/8/1.
//

import Foundation

extension String {
    func indent(with indentation: String = "    ") -> String {
        let components = self.components(separatedBy: "\n")
        return indentation + components.joined(separator: "\n\(indentation)")
    }

    func nextLine(_ code: String) -> String {
        return self + "\n" + code
    }
}
