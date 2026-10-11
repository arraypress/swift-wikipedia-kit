//
//  WikipediaNewsResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One "In the news" story: its HTML and the articles it links.
internal struct WikipediaNewsResponse: Decodable {
    let story: String
    let links: [WikipediaSummaryResponse]
}
