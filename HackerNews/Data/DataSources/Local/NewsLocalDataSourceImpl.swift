//
//  NewsLocalDataSourceImpl.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation
import CoreData
import Combine

class NewsLocalDataSourceImpl: NewsLocalDataSource {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.context = context
    }

    func save(_ newsItem: [NewsItem]) -> AnyPublisher<Void, any Error> {
        return Future { [unowned self] promise in
            do {
                for item in newsItem {
                    let fetch = NewsItemEntity.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %d", item.id)
                    let results = try context.fetch(fetch)
                    let newsItemEntity = results.first ?? NewsItemEntity(context: context)
                    if results.isEmpty {
                        newsItemEntity.banned = false
                    }
                    newsItemEntity.update(from: item)
                }
                try context.save()
                return promise(.success(()))
            } catch {
                return promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    func fetchNews() -> AnyPublisher<[NewsItemEntity], Error> {
        return Future { [unowned self] promise in
            do {
                let fetchRequest = NewsItemEntity.fetchRequest()
                fetchRequest.sortDescriptors = [
                    NSSortDescriptor(key: "createdAtTimestamp", ascending: false)
                ]
                fetchRequest.predicate = NSPredicate(format: "banned == false")
                let results = try context.fetch(fetchRequest)
                return promise(.success(results))
            } catch {
                return promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    func ban(_ newsItem: NewsItem) -> AnyPublisher<Void, Error> {
        return Future { [unowned self] promise in
            do {
                let fetchRequest = NewsItemEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %d", newsItem.id)
                let newsItem = try context.fetch(fetchRequest).first
                newsItem?.banned = true
                try context.save()
                return promise(.success(()))
            } catch {
                return promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
