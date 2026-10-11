//
//  WikipediaPageViewsResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The Wikimedia pageviews `per-article` body.
internal struct WikipediaPageViewsResponse: Decodable {
    let items: [WikipediaPageViewsItem]
}
