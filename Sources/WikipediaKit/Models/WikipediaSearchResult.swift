//
//  WikipediaSearchResult.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// One article found by a search.
public struct WikipediaSearchResult: Sendable, Identifiable {

    /// Unique identifier (the page ID).
    public let id: Int

    /// Article title.
    public let title: String

    /// The matching passage as plain text: tags removed, entities decoded.
    public let snippet: String

    /// Wikipedia page ID.
    public let pageId: Int

    /// Total word count of the full article.
    public let wordCount: Int

    /// How well the result matches the query: 2 for each query word in the
    /// title, 1 for each found only in the snippet, averaged over the query's
    /// words — so 0.0 to 2.0.
    public let relevanceScore: Double

    internal init(title: String, snippet: String, pageId: Int, wordCount: Int, relevanceScore: Double) {
        self.id = pageId
        self.title = title
        self.snippet = snippet
        self.pageId = pageId
        self.wordCount = wordCount
        self.relevanceScore = relevanceScore
    }
}
