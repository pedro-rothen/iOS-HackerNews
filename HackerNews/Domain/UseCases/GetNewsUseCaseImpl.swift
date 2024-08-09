//
//  GetNewsUseCaseImpl.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation
import Combine

class GetNewsUseCaseImpl: GetNewsUseCase {
    let newsRepository: NewsRepository

    init(newsRepository: NewsRepository) {
        self.newsRepository = newsRepository
    }

    func execute(page: Int) -> AnyPublisher<[NewsItem], Error> {
        newsRepository.fetchNews(page: page)
    }
}
