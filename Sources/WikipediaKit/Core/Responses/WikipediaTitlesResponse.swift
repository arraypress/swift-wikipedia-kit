//
//  WikipediaTitlesResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A summary's `titles`. `normalized` is the readable title; the summary's own
/// `title` is the page key in the daily feed — "List_of_equations" — though the
/// summary endpoint itself sends the readable form.
internal struct WikipediaTitlesResponse: Codable {
    let normalized: String?
}
