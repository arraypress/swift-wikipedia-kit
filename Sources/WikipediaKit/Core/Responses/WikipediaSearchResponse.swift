//
//  WikipediaSearchResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The `action=query&list=search` envelope.
internal struct WikipediaSearchResponse: Codable {
    let query: WikipediaSearchQuery
}
