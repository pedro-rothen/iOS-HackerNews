//
//  HNResult.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation

struct HNResult: Decodable {
    let createdAtTimestamp: Int
    let objectId: String
    let author, createdAt: String
    let title, storyTitle, storyUrl: String?

    enum CodingKeys: String, CodingKey {
        case objectId = "objectID"
        case author
        case createdAt = "created_at"
        case title
        case storyTitle = "story_title"
        case storyUrl = "story_url"
        case createdAtTimestamp = "created_at_i"
    }
}
