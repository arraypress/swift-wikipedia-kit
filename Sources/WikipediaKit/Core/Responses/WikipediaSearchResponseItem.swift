//
//  WikipediaSearchResponseItem.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One hit of a search response; `snippet` is HTML.
internal struct WikipediaSearchResponseItem: Codable {
    let title: String
    let snippet: String
    let pageid: Int
    let wordcount: Int
}
