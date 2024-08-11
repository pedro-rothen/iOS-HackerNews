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
                $0.compactMap {
                    NewsItemMapper.map($0)
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
