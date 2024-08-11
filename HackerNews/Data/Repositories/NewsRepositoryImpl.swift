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
            .tryCatch { error in
                /// If the error is related to connectivity, an empty object is returned to continue the pipeline.
                /// If it's another error it's returned immediately to show the failure UI
                switch error as? HNServiceServiceError {
                case .networkError(let error):
                    if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                        return Just([HNResult]())
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    fallthrough
                default:
                    throw error
                }
            }
            .map {
                /// Mapping the remote objects to domain ones
                $0.compactMap {
                    NewsItemMapper.map($0)
                }
            }
            .flatMap { [localDataSource] (items: [NewsItem]) in
                // Saving latest copy to local storage
                _ = localDataSource.save(items)
                // Always reading from local storage to support offline mode
                return localDataSource.fetchNews()
            }
            .map {
                /// Local object to domain one
                $0.compactMap{ $0.toDomain }
            }.eraseToAnyPublisher()
    }

    func ban(_ newsItem: NewsItem) -> AnyPublisher<Void, Error> {
        // Bans the specify item, does not appear again even from remote refresh
        localDataSource
            .ban(newsItem)
    }
}

/// Helpers
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
