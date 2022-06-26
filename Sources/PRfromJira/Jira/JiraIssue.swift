//
//  JiraIssue.swift
//
//
//  Created by 류성두 on 2022/06/26.
//

import Foundation

struct JiraIssue {
    let key: String
    let summary: String
    let description: String
    let parentKey: String?
    let isEpic: Bool
    let isSubTask: Bool
    let attachments: [String]
}
