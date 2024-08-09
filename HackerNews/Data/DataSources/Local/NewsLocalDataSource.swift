//
//  NewsLocalDataSource.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation
import Combine

protocol NewsLocalDataSource {
    func save(_ newsItem: [NewsItem]) -> AnyPublisher<Void, Error>
    func fetchNews() -> AnyPublisher<[NewsItemEntity], Error>
    func ban(_ newsItem: NewsItem) -> AnyPublisher<Void, Error>
}
