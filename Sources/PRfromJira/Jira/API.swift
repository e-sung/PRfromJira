//
//  API.swift
//  
//
//  Created by 류성두 on 2022/06/26.
//

import Foundation

func networkError(for statusCode: Int, on key: String) -> JiraError? {
    if statusCode == 401 {
        let apiTokenDocumentURL = "https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/#supply-basic-auth-headers"
        return JiraError(
            errorDescription: "토큰이 잘못되었거나 만료되었습니다",
            recoverySuggestion: "\(apiTokenDocumentURL)을 참고하여 새롭게 API Key를 생성하여 \(rcFileLocation) 파일의 내용을 최신화해주세요"
        )
    } else if statusCode >= 400 && statusCode < 500 {
        return JiraError(
            errorDescription: "\(key)에 해당하는 이슈가 없습니다",
            recoverySuggestion: "해당 이슈가 삭제되었거나 이동되었을 수 있습니다"
        )
    } else if statusCode >= 500 {
        return JiraError(
            errorDescription: "Jira서버에서 500이 내려옵니다",
            recoverySuggestion: "박준호님에게 문의해주세요"
        )
    } else {
        return nil
    }
}

func fetchJiraIssue(from key: String) async throws -> JiraIssue {
    let request = try createRequest(with: key)
    let response = try await URLSession.shared.data(for: request)
    let statusCode = (response.1 as! HTTPURLResponse).statusCode
    if let networkError = networkError(for: statusCode, on: key) {
        throw networkError
    }
    
    let data = response.0

    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let fields = json?["fields"] as? [String: Any] ?? [:]
    let summary = fields["summary"] as? String ?? ""
    var description = fields["description"] as? String ?? ""
    description = try description.removeAllSmartLinks()
    description = try description.removeAllJiraLink()
    description = try description.removeAttachments()
    description = try description.convertSlackLink()
    let parent = fields["parent"] as! [String: Any]
    let parentKey = parent["key"] as! String

    let issueType = fields["issuetype"] as! [String: Any]
    let isSubTask = issueType["subtask"] as! Bool
    let isEpic = (issueType["name"] as! String) == "Epic"

    let attachments = (fields["attachment"] as? [[String: Any]])?.compactMap { $0["content"] as? String }

    return JiraIssue(
        key: key,
        summary: summary,
        description: description,
        parentKey: parentKey,
        isEpic: isEpic,
        isSubTask: isSubTask,
        attachments: attachments ?? []
    )
}


func fetchReferenceLinks(from issue: JiraIssue) async throws -> ReferenceLinks {
    if issue.isEpic == false, issue.isSubTask == false {
        return try await fetchReferenceLinks(from: issue.parentKey!)
    } else if issue.isEpic {
        return try await fetchReferenceLinks(from: issue.key)
    } else {
        let parentIssue = try await fetchJiraIssue(from: issue.parentKey!)
        return try await fetchReferenceLinks(from: parentIssue.parentKey!)
    }
}

func fetchReferenceLinks(from epicKey: String) async throws -> ReferenceLinks {
    let request = try createRequest(with: epicKey)
    let response = try await URLSession.shared.data(for: request).0
    let data = try JSONSerialization.jsonObject(with: response) as! [String: Any]
    let fields = data["fields"] as! [String: Any]
    let designSpec = fields["customfield_10746"] as? String
    let techSpec = fields["customfield_10747"] as? String
    let productSpec = fields["customfield_10667"] as? String
    let experimentSpec = fields["customfield_10433"] as? String
    let testResultLink = fields["customfield_10750"] as? String

    return ReferenceLinks(
        productSpec: productSpec,
        techSpec: techSpec,
        designSpec: designSpec,
        experimentSpec: experimentSpec,
        testResultLink: testResultLink
    )
}

func createRequest(with key: String) throws -> URLRequest {
    var request = URLRequest(url: URL(string: "https://banksalad.atlassian.net/rest/api/2/issue/\(key)")!)
    let token = try getTokenFromDisk()
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
    return request
}


let rcFileName = "createPRrc"
let rcFileLocation = "~/.\(rcFileName)"
func getTokenFromDisk() throws -> String {
    let documentPath = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
    let homePath = documentPath.deletingLastPathComponent()
    let url = homePath.appendingPathComponent(".\(rcFileName)")
    do {
        let token = try String(contentsOf: url, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        return token
    } catch {
        throw JiraError(
            errorDescription: "\(rcFileLocation) 파일이 없습니다",
            recoverySuggestion: "README를 참고하여 \(rcFileLocation) 파일을 생성하고, API Key를 저장해주세요."
        )
    }
}

struct JiraError: LocalizedError {
    let errorDescription: String?
    let recoverySuggestion: String?
}
