//
//  NewsFeedDetail.swift
//  HackerNews
//
//  Created by Pedro on 11-08-24.
//

import SwiftUI
import WebKit

struct NewsFeedDetail: View {
    let newsItem: NewsItem

    var body: some View {
        if let url = URL(string: newsItem.link) {
            WebView(url: url)
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

#Preview {
    let newsItem = NewsItem(
        id: 0,
        createdAtTimestamp: 1723150014,
        title: "Apple is America's semiconductor problem",
        author: "blackeyeblitzar",
        createdAt: "2024-08-08T20:46:54Z",
        link: "https://www.semiconductor-digest.com/apple-is-americas-semiconductor-problem/"
    )
    return NewsFeedDetail(newsItem: newsItem)
}
