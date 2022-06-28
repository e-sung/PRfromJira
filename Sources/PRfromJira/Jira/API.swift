//
//  API.swift
//
//
//  Created by 류성두 on 2022/06/26.
//

import Foundation

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
    let parent = fields["parent"] as? [String: Any]
    let parentKey = parent?["key"] as? String

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

func fetchReferenceLinks(from issue: JiraIssue) async throws -> ReferenceLinks? {
    if issue.isEpic == false, issue.isSubTask == false {
        return try await fetchReferenceLinks(from: issue.parentKey)
    } else if issue.isEpic {
        return try await fetchReferenceLinks(from: issue.key)
    } else if let parentKey = issue.parentKey {
        let parentIssue = try await fetchJiraIssue(from: parentKey)
        return try await fetchReferenceLinks(from: parentIssue.parentKey)
    } else {
        return nil
    }
}

func fetchReferenceLinks(from epicKey: String?) async throws -> ReferenceLinks? {
    guard let epicKey = epicKey else {
        return nil
    }
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
    guard let host = URL(string: try getJiraHostFromDisk()) else {
        throw JiraError(
            errorDescription: "\(rcFileName)에 적힌 HOST 주소의 형식이 부적절합니다",
            recoverySuggestion: "\(rcFileName)에 적힌 HOST 주소를 다시 한 번 확인해주세요"
        )
    }
    let issueURL = URL(string: "\(host)/rest/api/2/issue/\(key)")!
    var request = URLRequest(url: issueURL)
    let token = try getTokenFromDisk()
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
    return request
}
