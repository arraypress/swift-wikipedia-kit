//
//  WikipediaMostReadResponse.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// The feed's `mostread` section.
internal struct WikipediaMostReadResponse: Decodable {
    let articles: [WikipediaMostReadArticleResponse]
}
