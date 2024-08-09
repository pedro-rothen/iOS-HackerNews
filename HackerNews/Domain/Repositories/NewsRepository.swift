//
//  NewsRepository.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation
import Combine

protocol NewsRepository {
    func fetchNews(page: Int) -> AnyPublisher<[NewsItem], Error>
}
