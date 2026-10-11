//
//  WikipediaGeoSearchQuery.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The `query` object of a geosearch.
internal struct WikipediaGeoSearchQuery: Decodable {
    let geosearch: [WikipediaGeoSearchItem]
}
