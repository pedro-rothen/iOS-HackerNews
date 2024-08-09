//
//  HNServiceImpl.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation
import Combine

class HNServiceImpl: HNServiceApi {
    let session: URLSessionProtocol
    private let baseUrl = "https://hn.algolia.com/api/v1/"

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func fetchNews(page: Int) -> AnyPublisher<[HNResult], Error> {
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.path += "search_by_date"
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: "mobile"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        guard let url = urlComponents?.url else {
            return Fail(error: HNServiceServiceError.badUrl).eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)

        return session.dataTaskPublisher(request: request)
            .mapError {
                #if DEBUG
                print("Error: \($0)")
                #endif
                return HNServiceServiceError.networkError($0)
            }
            .map { data, response in
                #if DEBUG
                print(data)
                print(response)
                #endif
                return data
            }
            .decode(type: HNResponse.self, decoder: JSONDecoder())
            .mapError {
                if $0 is HNServiceServiceError {
                    return $0
                }
                return HNServiceServiceError.decodingError($0)
            }
            .map { $0.hits }
            .eraseToAnyPublisher()
    }
}

enum HNServiceServiceError: Error {
    case badUrl
    case networkError(Error)
    case decodingError(Error)
}

public protocol URLSessionProtocol {
    func dataTaskPublisher(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: URLSessionProtocol {
    public func dataTaskPublisher(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        return dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
    }
}
