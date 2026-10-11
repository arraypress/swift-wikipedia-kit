//
//  WikipediaSummaryResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The REST `page/summary` body — also the shape of the random article and of the featured feed's `tfa`.
internal struct WikipediaSummaryResponse: Codable {
    let title: String
    let extract: String
    let description: String?
    let thumbnail: WikipediaThumbnailResponse?
    let content_urls: WikipediaContentURLs
    let pageid: Int
    let timestamp: Date?
}
