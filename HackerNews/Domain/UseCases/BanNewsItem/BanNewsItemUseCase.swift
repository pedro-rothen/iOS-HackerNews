//
//  BanNewsItemUseCase.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation
import Combine

protocol BanNewsItemUseCase {
    func execute(_ item: NewsItem) -> AnyPublisher<Void, Error>
}
