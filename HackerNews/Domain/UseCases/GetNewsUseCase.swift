//
//  GetNewsUseCase.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation
import Combine

protocol GetNewsUseCase {
    func execute(page: Int) -> AnyPublisher<[NewsItem], Error>
}
