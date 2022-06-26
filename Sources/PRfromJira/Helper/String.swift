//
//  String.swift
//
//
//  Created by 류성두 on 2022/06/27.
//

import Foundation

extension String {
    func matchingSubstring(for regexPattern: String) throws -> String {
        let range = NSRange(startIndex..., in: self)
        let regex = try NSRegularExpression(pattern: regexPattern)
        let matches = regex.matches(in: self, range: range)
        guard let firstMatch = matches.first else {
            return ""
        }
        return NSString(string: self).substring(with: firstMatch.range)
    }

    func replace(target: String, with replaceText: String) -> String {
        return replacingOccurrences(
            of: target,
            with: replaceText,
            options: NSString.CompareOptions.literal,
            range: nil
        )
    }
}
