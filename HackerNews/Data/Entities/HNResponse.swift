//
//  HNResponse.swift
//  HackerNews
//
//  Created by Pedro on 08-08-24.
//

import Foundation

struct HNResponse: Decodable {
    let hits: [HNResult]
}
