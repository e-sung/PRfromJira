import Foundation

@main
public struct main {

    public static func main() async {
        do {
            let branch = shell("git branch --show-current")!
            let key = branch.components(separatedBy: "/")[1].replacingOccurrences(of: "\n", with: "")

            let issue = try await fetchJiraIssue(from: key)
            let links = try await fetchReferenceLinks(from: issue)
            let prBody = createPRBody(with: issue, references: links)
            let prTitle = "[\(key)] \(issue.summary)"
            let script = """
                         gh pr create --assignee @me --base develop --body "\(prBody)" --title "\(prTitle)" --web
                         """
            _ = shell(script)
            print("\(prTitle)을 기반으로 PR 을 생성했습니다!")
        } catch {
            print(error.localizedDescription)
            if let recoverySuggestion = (error as? LocalizedError)?.recoverySuggestion {
                print(recoverySuggestion)
            }
        }
    }
}

func shell(_ command: String) -> String? {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)

    return output
}

func createPRBody(with issue: JiraIssue, references: ReferenceLinks?) -> String {
    var result = "## What is this PR? 🔍\n"
    if let productSpec = references?.productSpec {
        result += "* [프로덕트스펙](\(productSpec))\n"
    }
    if let techSpec = references?.techSpec {
        result += "* [테크스펙](\(techSpec))\n"
    }
    if let designSpec = references?.designSpec {
        result += "* [Figma](\(designSpec))\n"
    }
    if let experimentSpec = references?.experimentSpec {
        result += "* [실험문서](\(experimentSpec))\n"
    }
    if let testResultLink = references?.testResultLink {
        result += "* [테스트결과](\(testResultLink))\n"
    }
    result += "\n"
    result += issue.description

    if issue.attachments.isEmpty == false {
        result += "## Attachments\n"
        for attachment in issue.attachments {
            result += "\(attachment)\n"
        }
    }

    result += """
    
    ## Changes :memo:

    ## Screenshot :camera:

    기능 | 스크린샷
    --- | ---
    (feature) | ![img](imgurl)

    ## **BaseViewController** 변경사항 체크
    - [ ] : `BaseViewController.swift` 의 내용이 변경되었다면
    - [ ] : `BSViewController.swift` 에도 동일한 내용을 반영해 주세요 :-)

    ## PR 내에 `실험,피쳐플래그` 포함될 경우 대조군(Control) 테스트 완료여부
    - 꼭 대조군  테스트를 진행한 후에 check-box 에 체크해주세요.
    - commit 을 새로 push 한 이후에는 check-box 를 해제해주세요.
    - PR 이 머지되기 전에 꼭 check-box 에 체크가 완료되어야 합니다.
    - [ ] : 대조군 테스트 완료했음

    ## Test Checklist :ballot_box_with_check:

    ## Convention & Formatter
    더 빠른 코드리뷰를 위해 아래 항목을 스스로 확인해주세요!
    - [ ] [코드 스타일 가이드](https://www.notion.so/banksalad/9ff442f5c47e4db0a0f1b070af3f07e1) 반영 여부
    - [ ] SwiftFormat 적용 여부 (1.Xcode 에서 Project Run 실행 or 2.shell 에서 `make format` 실행)
    """
    return result
}
