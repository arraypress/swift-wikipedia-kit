//
//  WikipediaSearchResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 03/08/2025.
//

import Foundation

/// Internal model for Wikipedia search API response
internal struct WikipediaSearchResponse: Codable {
    let query: WikipediaSearchQuery
}

internal struct WikipediaSearchQuery: Codable {
    let search: [WikipediaSearchResponseItem]
}

internal struct WikipediaSearchResponseItem: Codable {
    let title: String
    let snippet: String
    let pageid: Int
    let wordcount: Int
}

/// Internal model for Wikipedia summary API response
internal struct WikipediaSummaryResponse: Codable {
    let title: String
    let extract: String
    let description: String?
    let thumbnail: WikipediaThumbnailResponse?
    let content_urls: WikipediaContentURLs
    let pageid: Int
    let timestamp: Date?
}

internal struct WikipediaThumbnailResponse: Codable {
    let source: String
    let width: Int
    let height: Int
}

internal struct WikipediaContentURLs: Codable {
    let desktop: WikipediaDesktopURL
}

internal struct WikipediaDesktopURL: Codable {
    let page: URL
}

/// Internal model for Wikipedia featured article response
internal struct WikipediaFeaturedResponse: Codable {
    let tfa: WikipediaSummaryResponse
}
