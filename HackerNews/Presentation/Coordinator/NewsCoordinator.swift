//
//  NewsCoordinator.swift
//  HackerNews
//
//  Created by Pedro on 11-08-24.
//

import Foundation

// This should be a protocol to mock it while doing testing
@MainActor
class NewsCoordinator: ObservableObject {
    @Published var navigationPath: [NewsItem] = []

    func showNewsItemDetail(_ newsItem: NewsItem) {
        navigationPath.append(newsItem)
    }
}
