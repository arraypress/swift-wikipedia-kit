//
//  WikipediaFeaturedResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The featured feed for a day; `tfa` is today's featured article.
internal struct WikipediaFeaturedResponse: Codable {
    let tfa: WikipediaSummaryResponse
}
