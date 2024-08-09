//
//  NewsRepositoryImpl.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation
import Combine

class NewsRepositoryImpl: NewsRepository {
    let remoteDataSource: HNServiceApi
    let localDataSource: NewsLocalDataSource

    init(remoteDataSource: HNServiceApi, localDataSource: NewsLocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchNews(page: Int) -> AnyPublisher<[NewsItem], Error> {
        remoteDataSource
            .fetchNews(page: page)
            .map {
                $0.compactMap {
                    guard let id = Int($0.objectId),
                            let title = $0.title ?? $0.storyTitle, let link = $0.storyUrl else {
                        return nil
                    }
                    return NewsItem(
                        id: id,
                        createdAtTimestamp: $0.createdAtTimestamp,
                        title: title,
                        author: $0.author,
                        createdAt: $0.createdAt,
                        link: link
                    )
                }
            }
            .flatMap { [localDataSource] (items: [NewsItem]) in
                _ = localDataSource.save(items)
                return localDataSource.fetchNews()
            }
            .map {
                $0.compactMap{ $0.toDomain }
            }.eraseToAnyPublisher()
    }

    func ban(_ newsItem: NewsItem) -> AnyPublisher<Void, Error> {
        localDataSource
            .ban(newsItem)
    }
}

extension NewsItemEntity {
    var toDomain: NewsItem? {
        guard let title, let author, let createdAt, let link else { return nil }
        return NewsItem(
            id: Int(id), 
            createdAtTimestamp: Int(createdAtTimestamp),
            title: title,
            author: author, 
            createdAt: createdAt,
            link: link
        )
    }

    func update(from newsItem: NewsItem) {
        self.id = Int32(newsItem.id)
        self.createdAtTimestamp = Int32(newsItem.createdAtTimestamp)
        self.title = newsItem.title
        self.author = newsItem.author
        self.createdAt = newsItem.createdAt
        self.link = newsItem.link
    }
}
