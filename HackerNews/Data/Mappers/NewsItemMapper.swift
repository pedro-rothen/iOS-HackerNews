//
//  NewsItemMapper.swift
//  HackerNews
//
//  Created by Pedro on 11-08-24.
//

import Foundation

struct NewsItemMapper {
    static func map(_ hnResult: HNResult) -> NewsItem? {
        guard let id = Int(hnResult.objectId),
                let title = hnResult.title ?? hnResult.storyTitle,
                let link = hnResult.storyUrl else {
            return nil
        }
        return NewsItem(
            id: id,
            createdAtTimestamp: hnResult.createdAtTimestamp,
            title: title,
            author: hnResult.author,
            createdAt: hnResult.createdAt,
            link: link
        )
    }
}
