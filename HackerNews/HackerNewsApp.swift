//
//  HackerNewsApp.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import SwiftUI

@main
struct HackerNewsApp: App {
    let persistenceController = PersistenceController.shared
    let newsFeedViewModel: NewsFeedViewModel

    init() {
        newsFeedViewModel = NewsFeedViewModel(
            getNewsUseCase: GetNewsUseCaseImpl(
                newsRepository: NewsRepositoryImpl(
                    remoteDataSource: HNServiceImpl()
                )
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            NewsFeedView(viewModel: newsFeedViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
