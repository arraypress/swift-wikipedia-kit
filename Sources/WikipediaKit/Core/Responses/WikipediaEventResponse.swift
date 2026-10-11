//
//  WikipediaEventResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One on-this-day entry: its text, its year (holidays have none) and the
/// articles it mentions.
internal struct WikipediaEventResponse: Decodable {
    let text: String
    let year: Int?
    let pages: [WikipediaSummaryResponse]?
}
