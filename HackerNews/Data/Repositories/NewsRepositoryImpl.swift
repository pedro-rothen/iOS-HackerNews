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

    init(remoteDataSource: HNServiceApi) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchNews(page: Int) -> AnyPublisher<[NewsItem], Error> {
        remoteDataSource
            .fetchNews(page: page)
            .map {
                $0.compactMap {
                    guard let title = $0.title ?? $0.storyTitle,
                            let link = $0.storyUrl else {
                        return nil
                    }
                    return NewsItem(
                        title: title,
                        author: $0.author,
                        createdAt: $0.createdAt,
                        link: link
                    )
                }
            }.eraseToAnyPublisher()
    }
}
