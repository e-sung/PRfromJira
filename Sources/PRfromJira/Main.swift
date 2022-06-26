import Foundation

@main
public struct main {
    public static func main() async {
        do {
            let arguments = CommandLine.arguments
            if arguments.count == 1 {
                try await createPRFromJiraIssue()
            } else {
                printHelp(for: arguments)
            }
        } catch {
            print(error.localizedDescription)
            if let recoverySuggestion = (error as? LocalizedError)?.recoverySuggestion {
                print(recoverySuggestion)
            }
            print("기타 도움말을 얻고 싶으면 `createPR --help` 를 사용해주세요")
        }
    }
}

func readGuide(for docName: String) -> String? {
    let url = Bundle.module.url(forResource: docName, withExtension: "md")!
    return try? String(contentsOf: url, encoding: .utf8)
}

func printHelp(for arguments: [String]) {
    if arguments.count == 3 {
        if let guideName = arguments.last?.uppercased(),
           let guideContent = readGuide(for: guideName)
        {
            print(guideContent)
        } else {
            printHelpHint()
        }
    } else {
        printHelpHint()
    }
}

func printHelpHint() {
    print("설정방법을 알고싶으면 `createPR --help setup` 을 입력하세요")
    print("사용방법을 알고싶으면 `createPR --help usage` 을 입력하세요")
}
