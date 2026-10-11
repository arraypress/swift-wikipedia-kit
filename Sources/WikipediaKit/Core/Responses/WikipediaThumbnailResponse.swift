//
//  WikipediaThumbnailResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A summary's thumbnail.
internal struct WikipediaThumbnailResponse: Codable {
    let source: String
    let width: Int
    let height: Int
}
