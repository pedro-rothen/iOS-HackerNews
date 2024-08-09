//
//  BanNewsItemUseCaseImpl.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation
import Combine

class BanNewsItemUseCaseImpl: BanNewsItemUseCase {
    var newsRepository: NewsRepository

    init(newsRepository: NewsRepository) {
        self.newsRepository = newsRepository
    }

    func execute(_ item: NewsItem) -> AnyPublisher<Void, Error> {
        newsRepository.ban(item)
    }
}
