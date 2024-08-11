//
//  HackerNewsApp.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import SwiftUI

@main
struct HackerNewsApp: App {
    @StateObject var coordinator = NewsCoordinator()
    let newsFeedViewModel: NewsFeedViewModel

    init() {
        let newsRepository = NewsRepositoryImpl(
            remoteDataSource: HNServiceImpl(),
            localDataSource: NewsLocalDataSourceImpl()
        )
        let viewModel = NewsFeedViewModel(
            getNewsUseCase: GetNewsUseCaseImpl(
                newsRepository: newsRepository
            ), baneNewsItemUseCase: BanNewsItemUseCaseImpl(
                newsRepository: newsRepository
            )
        )
        newsFeedViewModel = viewModel
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.navigationPath) {
                NewsFeedView(
                    viewModel: newsFeedViewModel, 
                    coordinator: coordinator
                ).navigationDestination(for: NewsItem.self) {
                    NewsFeedDetail(newsItem: $0)
                }
            }
        }
    }
}
