//
//  NewsFeedView.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import SwiftUI
import Combine

struct NewsFeedView: View {
    @StateObject var viewModel: NewsFeedViewModel

    var body: some View {
        ZStack {
            Group {
                switch viewModel.uiState {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView()
                        .controlSize(.large)
                case .success:
                    List(viewModel.news, id: \.self) { newsItem in
                        Text(newsItem.title)
                    }
                case .failed:
                    Button(action: {
                        viewModel.getNews()
                    }) {
                        Text("Retry 😔")
                    }
                }
            }
        }.onAppear {
            viewModel.getNews()
        }
    }
}

@MainActor
class NewsFeedViewModel: ObservableObject {
    @Published var news = [NewsItem]()
    @Published var uiState: NewsFeedUiState = .idle
    let getNewsUseCase: GetNewsUseCase
    var cancellables = Set<AnyCancellable>()

    init(getNewsUseCase: GetNewsUseCase) {
        self.getNewsUseCase = getNewsUseCase
    }

    func getNews() {
        uiState = .loading
        getNewsUseCase
            .execute(page: 1)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.uiState = .success
                case .failure(_):
                    self?.uiState = .failed
                }
            }, receiveValue: { [weak self] in
                self?.news = $0
            }).store(in: &cancellables)
    }
}

enum NewsFeedUiState {
    case idle, loading, success, failed
}

#Preview {
    let viewModel = NewsFeedViewModel(
        getNewsUseCase: GetNewsUseCaseImpl(
            newsRepository: NewsRepositoryImpl(
                remoteDataSource: HNServiceImpl()
            )
        )
    )
    return NewsFeedView(viewModel: viewModel)
}
