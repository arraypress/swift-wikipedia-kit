//
//  WikipediaMostReadArticleResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One most-read article: a page summary plus its views and rank, in one
/// JSON object, so both are decoded from the same decoder.
internal struct WikipediaMostReadArticleResponse: Decodable {
    let summary: WikipediaSummaryResponse
    let views: Int
    let rank: Int

    private enum CodingKeys: String, CodingKey { case views, rank }

    init(from decoder: Decoder) throws {
        summary = try WikipediaSummaryResponse(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        views = try container.decode(Int.self, forKey: .views)
        rank = try container.decode(Int.self, forKey: .rank)
    }
}
