//
//  NewsFeedView.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import SwiftUI
import Combine
import WebKit

struct NewsFeedView: View {
    @StateObject var viewModel: NewsFeedViewModel
    let coordinator: NewsCoordinator

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
                        VStack(alignment: .leading) {
                            Text(newsItem.title)
                                .font(.title3)
                            Text("\(newsItem.author) - \(styled(stringDate: newsItem.createdAt))")
                                .foregroundColor(.gray)
                        }.swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.ban(newsItem: newsItem)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }.onTapGesture {
                            coordinator.showNewsItemDetail(newsItem)
                        }
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
            viewModel.refreshIfNeeded()
        }.refreshable {
            viewModel.getNews()
        }
    }

    func styled(stringDate: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: stringDate) else {
            return stringDate
        }
        return timeAgo(from: date)
    }

    /// Ago formatting was required from mockup
    func timeAgo(from date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let day = components.day, day >= 2 {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            return formatter.string(from: date)
        } else if let day = components.day, day == 1 {
            return "yesterday"
        } else if let hour = components.hour, hour >= 1 {
            return "\(hour)h ago"
        } else if let minute = components.minute, minute >= 1 {
            return "\(minute) min ago"
        } else {
            return "just now"
        }
    }
}

@MainActor
class NewsFeedViewModel: ObservableObject {
    @Published var news = [NewsItem]()
    @Published var uiState: NewsFeedUiState = .idle
    let getNewsUseCase: GetNewsUseCase
    let baneNewsItemUseCase: BanNewsItemUseCase
    var cancellables = Set<AnyCancellable>()

    init(getNewsUseCase: GetNewsUseCase, baneNewsItemUseCase: BanNewsItemUseCase) {
        self.getNewsUseCase = getNewsUseCase
        self.baneNewsItemUseCase = baneNewsItemUseCase
    }

    func refreshIfNeeded() {
        // Avoids refreshing if already has items
        if news.isEmpty {
            getNews()
        }
    }

    func getNews() {
        uiState = .loading
        getNewsUseCase
            .execute(page: 1) /// Challenge did not require infinite scrolling, bbut I did design the domain and data layer to support pagination in case if gets needed
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

    func ban(newsItem: NewsItem) {
        baneNewsItemUseCase
            .execute(newsItem)
            .sink(receiveCompletion: {
                completion in
                switch completion {
                case .finished:
                    break
                case .failure(let failure):
                    print(failure)
                }
            }, receiveValue: {
                print("News item banned")
            }).store(in: &cancellables)
    }
}

enum NewsFeedUiState {
    case idle, loading, success, failed
}

#Preview {
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
    return NewsFeedView(viewModel: viewModel, coordinator: NewsCoordinator())
}
