//
//  File.swift
//
//
//  Created by 류성두 on 2022/06/27.
//

import Foundation

let rcFileName = "createPRrc"
let rcFileLocation = "~/.\(rcFileName)"

func getRcFileContentsFromDisk() throws -> String {
    let documentPath = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    let homePath = documentPath.deletingLastPathComponent()
    let url = homePath.appendingPathComponent(".\(rcFileName)")
    return try String(contentsOf: url, encoding: .utf8)
}

func getJiraHostFromDisk() throws -> String {
    do {
        let rcFile = try getRcFileContentsFromDisk()
        let hostPattern = "HOST: \(urlPattern)\\n"
        let urlLine = try rcFile.matchingSubstring(for: hostPattern)
        if urlLine.isEmpty {
            throw JiraError(
                errorDescription: "\(rcFileName)에서 지라 Host를 찾을 수 없습니다",
                recoverySuggestion: "`createPR --help setup` 을 참고해주세요"
            )
        }
        let host = urlLine.components(separatedBy: "HOST:").last?.trimmingCharacters(in: .whitespacesAndNewlines)
        return host!
    } catch {
        throw JiraError(
            errorDescription: "\(rcFileLocation) 파일이 없거나 손상되었습니다",
            recoverySuggestion: "`createPR --help setup` 을 참고해주세요"
        )
    }
}

func getTokenFromDisk() throws -> String {
    do {
        let rcFile = try getRcFileContentsFromDisk()
        let tokenPattern = "TOKEN: (.*?)\\n"
        let tokenLine = try rcFile.matchingSubstring(for: tokenPattern)
        if tokenLine.isEmpty {
            throw JiraError(
                errorDescription: "\(rcFileName)에서 지라 API토큰을 찾을 수 없습니다",
                recoverySuggestion: "`createPR --help setup` 을 참고해주세요"
            )
        }
        let token = tokenLine.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines)
        return token!
    } catch {
        throw JiraError(
            errorDescription: "\(rcFileLocation) 파일이 없거나 손상되었습니다",
            recoverySuggestion: "`createPR --help setup` 을 참고해주세요"
        )
    }
}

func getPRTemplateFromDisk() throws -> String {
    let rcFile = try getRcFileContentsFromDisk()
    let prTemplatePattern = "\nPR_TEMPLATE:\n"
    let prTemplate = rcFile.components(separatedBy: prTemplatePattern).last
    if let prTemplate = prTemplate {
        return prTemplate
    } else {
        throw JiraError(
            errorDescription: "\(rcFileName)에서 PR_TEMPLATE를 불러올 수 없었습니다",
            recoverySuggestion: "`createPR --help setup` 을 참고해주세요"
        )
    }
}
