//
//  WikipediaSummaryResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The REST `page/summary` body — also the shape of the random article, of the
/// daily feed's articles (featured, most read, news, on this day) and of the
/// on-this-day pages. Those embedded copies sometimes lack an extract or the
/// content URLs, so both are optional.
internal struct WikipediaSummaryResponse: Codable {
    let title: String
    let titles: WikipediaTitlesResponse?
    let extract: String?
    let description: String?
    let thumbnail: WikipediaThumbnailResponse?
    let content_urls: WikipediaContentURLs?
    let pageid: Int
    let timestamp: Date?
}
