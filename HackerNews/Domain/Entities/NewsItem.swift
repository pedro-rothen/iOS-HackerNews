//
//  NewsItem.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation

struct NewsItem: Hashable {
    let id, createdAtTimestamp: Int
    let title, author, createdAt, link: String
}
