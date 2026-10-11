//
//  WikipediaSearchQuery.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The `query` object of a search response.
internal struct WikipediaSearchQuery: Codable {
    let search: [WikipediaSearchResponseItem]
}
