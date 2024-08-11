//
//  NewsLocalDataSourceImplTests.swift
//  HackerNewsTests
//
//  Created by Pedro on 11-08-24.
//

import XCTest
import CoreData
import Combine
@testable import HackerNews

/// PDF did not ask for tests. But I wanted to do at least one for the most critical use case
final class NewsLocalDataSourceImplTests: XCTestCase {
    var localDataSource: NewsLocalDataSourceImpl!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        localDataSource = NewsLocalDataSourceImpl(
            context: InMemoryController().context
        )
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        localDataSource = nil
        cancellables.forEach { $0.cancel() }
        cancellables = nil
        super.tearDown()
    }

    func testBanNewsItemSuccessfully() throws {
        // Arrange
        let domainNews = NewsItemStub.newsItems
        let bannedNewsItem = domainNews.randomElement()!

        // Act
        let saveExpectation = expectation(description: "News items are saved to storage successfully")
        var receivedError: Error?
        var receivedDomainNewsItem: [NewsItem]?
        localDataSource
            .save(domainNews)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    saveExpectation.fulfill()
                case .failure(let failure):
                    receivedError = failure
                    saveExpectation.fulfill()
                }
            }, receiveValue: { })
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)

        let banExpectation = expectation(description: "Random news item is banned from local storage")
        localDataSource
            .ban(bannedNewsItem)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    banExpectation.fulfill()
                case .failure(let failure):
                    receivedError = failure
                    banExpectation.fulfill()
                }
            }, receiveValue: { })
            .store(in: &cancellables)
        waitForExpectations(timeout: 1)

        let fetchExpectation = expectation(description: "News items are fetch from storage successfully")
        localDataSource
            .fetchNews()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    fetchExpectation.fulfill()
                case .failure(let failure):
                    XCTFail(failure.localizedDescription)
                }
            }, receiveValue: {
                receivedDomainNewsItem = $0.compactMap { $0.toDomain}
            }).store(in: &cancellables)
        waitForExpectations(timeout: 1)

        // Assert
        XCTAssertNil(receivedError)
        XCTAssertNotNil(receivedDomainNewsItem)
        XCTAssertFalse(receivedDomainNewsItem!.contains(bannedNewsItem))
    }

    class InMemoryController {
        let container: NSPersistentContainer
        var context: NSManagedObjectContext {
            return container.viewContext
        }

        init() {
            container = NSPersistentContainer(name: "HackerNews")

            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]

            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Error while loading persistence storage \(error)")
                }
            }
        }
    }
}
