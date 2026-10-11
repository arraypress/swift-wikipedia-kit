//
//  WikipediaGeoSearchResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The `list=geosearch` envelope.
internal struct WikipediaGeoSearchResponse: Decodable {
    let query: WikipediaGeoSearchQuery
}
