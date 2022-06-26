//
//  JiraError.swift
//
//
//  Created by 류성두 on 2022/06/26.
//

import Foundation

struct JiraError: LocalizedError {
    let errorDescription: String?
    let recoverySuggestion: String?
}

func networkError(for statusCode: Int, on key: String) -> JiraError? {
    if statusCode == 401 {
        let apiTokenDocumentURL = "https://developer.atlassian.com/cloud/jira/platform/basic-auth-for-rest-apis/#supply-basic-auth-headers"
        return JiraError(
            errorDescription: "토큰이 잘못되었거나 만료되었습니다",
            recoverySuggestion: "\(apiTokenDocumentURL)을 참고하여 새롭게 API Key를 생성하여 \(rcFileLocation) 파일의 내용을 최신화해주세요"
        )
    } else if statusCode >= 400, statusCode < 500 {
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
