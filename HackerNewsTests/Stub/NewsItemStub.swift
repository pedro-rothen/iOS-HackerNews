//
//  NewsItemStub.swift
//  HackerNewsTests
//
//  Created by Pedro on 11-08-24.
//

import Foundation
@testable import HackerNews

protocol TestBundle: AnyObject { }
extension TestBundle {
    static var bundle: Bundle {
        return Bundle(for: Self.self)
    }
}

class NewsItemStub: TestBundle {
    class var jsonResponseUrl: URL {
        return bundle.url(
            forResource: "MockHNResponse",
            withExtension: "json"
        )!
    }
    class var newsItems: [NewsItem] {
        let data = try! Data(contentsOf: jsonResponseUrl)
        return try! JSONDecoder()
            .decode(HNResponse.self, from: data)
            .hits
            .compactMap { NewsItemMapper.map($0) }
    }
}
