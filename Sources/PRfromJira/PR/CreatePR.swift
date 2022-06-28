//
//  CreatePR.swift
//
//
//  Created by 류성두 on 2022/06/27.
//

import Foundation

func createPRFromJiraIssue() async throws {
    try checkPreconditions()

    let branch = shell("git branch --show-current")!
    guard let key = branch.components(separatedBy: "/").last?.replacingOccurrences(of: "\n", with: "") else {
        throw JiraError(
            errorDescription: "브랜치 이름에서 지라 이슈 키를 확인 할 수 없습니다",
            recoverySuggestion: "브랜치 이름의 형식이 feature/{지라이슈키} 와 같은지 확인해주세요"
        )
    }
    print("현재 브랜치의 지라 이슈를 가져옵니다...")
    let issue = try await fetchJiraIssue(from: key)
    print("연관된 링크들을 가져옵니다....")
    let links = try await fetchReferenceLinks(from: issue)
    let prBody = try createPRBody(with: issue, references: links)
    let prTitle = "[\(key)] \(issue.summary)"
    print("\(prTitle)을 기반으로 PR 생성중입니다...")
    let script = """
    gh pr create --assignee @me --base develop --body "\(prBody)" --title "\(prTitle)" --web
    """
    shell(script)
}

func createPRBody(with issue: JiraIssue, references: ReferenceLinks?) throws -> String {
    var result = try getPRTemplateFromDisk()
    var links = ""
    if let productSpec = references?.productSpec {
        links += "* [프로덕트스펙](\(productSpec))\n"
    }
    if let techSpec = references?.techSpec {
        links += "* [테크스펙](\(techSpec))\n"
    }
    links += "* 지라이슈: \(issue.key)"
    if let designSpec = references?.designSpec {
        links += "* [Figma](\(designSpec))\n"
    }
    if let experimentSpec = references?.experimentSpec {
        links += "* [실험문서](\(experimentSpec))\n"
    }
    if let testResultLink = references?.testResultLink {
        links += "* [테스트결과](\(testResultLink))\n"
    }

    result = result.replace(target: "%REFERENCE_LINKS%", with: links)
    result = result.replace(target: "%DESCRIPTION%", with: issue.description)

    var attachments = ""
    if issue.attachments.isEmpty == false {
        attachments += "## Attachments\n"
        for attachment in issue.attachments {
            attachments += "\(attachment)\n"
        }
    }
    result = result.replace(target: "%ATTACHMENTS%", with: attachments)

    return result
}

func checkPreconditions() throws {
    guard checkRCfileCreated() == true else {
        throw JiraError(
            errorDescription: "createPRrc 파일이 생성되지 않았습니다",
            recoverySuggestion: "createPR --help setup 명령을 참조해주세요"
        )
    }

    guard checkIfGithubCLIInstalled() == true else {
        throw JiraError(
            errorDescription: "Github CLI가 설치되지 않았습니다",
            recoverySuggestion: "https://github.com/cli/cli#installation 를 참고해 Github CLI를 설치해주세요"
        )
    }
}

func checkIfGithubCLIInstalled() -> Bool {
    let checkCommand = """
    if ! type gh > /dev/null; then
      echo "false"
    else
      echo "true"
    fi
    """
    let result = shell(checkCommand)?.trimmingCharacters(in: .whitespacesAndNewlines)
    return Bool(result ?? "false") ?? false
}

func checkRCfileCreated() -> Bool {
    let checkCommand = """
    if test -f \(rcFileLocation); then
      echo "true"
    else
      echo "false"
    fi
    """
    let result = shell(checkCommand)?.trimmingCharacters(in: .whitespacesAndNewlines)
    return Bool(result ?? "false") ?? false
}
