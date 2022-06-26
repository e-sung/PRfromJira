//
//  DescriptionCleanup.swift
//
//
//  Created by 류성두 on 2022/06/26.
//

import Foundation

let urlPattern = "https?:\\/\\/[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"

extension String {
    func removeAllSmartLinks() throws -> String {
        var result = self
        let pattern = "\\[\(urlPattern)\\|\(urlPattern)\\|smart-link\\]"
        let smartLinkRegex = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(startIndex..., in: self)
        let matches = smartLinkRegex.matches(in: self, range: range)
        let urls = matches.map { match in
            let matchedText = NSString(string: self).substring(with: match.range)
            let urlRegex = try! NSRegularExpression(pattern: urlPattern)
            let urlRange = urlRegex.rangeOfFirstMatch(in: matchedText, range: NSRange(startIndex..., in: matchedText))
            let url = NSString(string: matchedText).substring(with: urlRange)
            return url
        }

        urls.forEach { url in
            let pattern = "[\(url)|\(url)|smart-link]"
            let urlRepalceRegex = try! NSRegularExpression(pattern: pattern, options: [.ignoreMetacharacters])
            result = urlRepalceRegex.stringByReplacingMatches(in: result, range: NSRange(startIndex..., in: result), withTemplate: url)
        }
        return result
    }

    func removeAllJiraLink() throws -> String {
        var result = self
        let pattern = "\\[\\+\(urlPattern)\\+\\|\(urlPattern)\\]"
        let smartLinkRegex = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(startIndex..., in: self)
        let matches = smartLinkRegex.matches(in: self, range: range)
        let urls = matches.map { match in
            let matchedText = NSString(string: self).substring(with: match.range)
            let urlRegex = try! NSRegularExpression(pattern: urlPattern)
            let urlRange = urlRegex.rangeOfFirstMatch(in: matchedText, range: NSRange(startIndex..., in: matchedText))
            var url = NSString(string: matchedText).substring(with: urlRange)
            if url.last == "+" {
                _ = url.popLast()
            }
            return url
        }

        urls.forEach { url in
            let pattern = "[+\(url)+|\(url)"
            let urlRepalceRegex = try! NSRegularExpression(pattern: pattern, options: [.ignoreMetacharacters])
            let range = NSRange(startIndex..., in: result)
            result = urlRepalceRegex.stringByReplacingMatches(in: result, range: range, withTemplate: url)
            if result.last == "]" {
                _ = result.popLast()
            }
        }
        return result
    }

    func convertSlackLink() throws -> String {
        var result = self
        let pattern = "\\_Issue created in Slack from a\\_ \\[\\_message\\_\\|\(urlPattern)\\]\\_\\.\\_"
        let range = NSRange(startIndex..., in: self)
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: self, range: range)
        let urls = matches.map { match in
            let matchedText = NSString(string: self).substring(with: match.range)
            let urlRegex = try! NSRegularExpression(pattern: urlPattern)
            let urlRange = urlRegex.rangeOfFirstMatch(in: matchedText, range: NSRange(startIndex..., in: matchedText))
            let url = NSString(string: matchedText).substring(with: urlRange)
            return url
        }

        urls.forEach { url in
            let urlRepalceRegex = try! NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(startIndex..., in: result)
            result = urlRepalceRegex.stringByReplacingMatches(in: result, range: range, withTemplate: "[슬랙메시지](\(url))")
        }
        return result
    }

    func removeAttachments() throws -> String {
        var result = self
        let pattern = "\\!(.*?)\\|width\\=\\d+\\,height\\=\\d+\\!"
        let range = NSRange(startIndex..., in: self)
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        result = regex.stringByReplacingMatches(in: result, range: range, withTemplate: "")

        return result
    }
}
