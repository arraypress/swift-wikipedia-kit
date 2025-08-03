//
//  WikipediaSearchResult.swift
//  WikipediaKit
//
//  Created by David Sherlock on 03/08/2025.
//

import Foundation

/// Represents a Wikipedia search result.
///
/// Contains metadata about articles found in search results,
/// including relevance scoring and content snippets.
public struct WikipediaSearchResult: Sendable, Identifiable {
    /// Unique identifier (same as pageId)
    public let id: Int
    
    /// Article title
    public let title: String
    
    /// Search result snippet with highlighted content
    public let snippet: String
    
    /// Wikipedia page ID
    public let pageId: Int
    
    /// Total word count of the full article
    public let wordCount: Int
    
    /// Relevance score for this search result (0.0 - 1.0+)
    ///
    /// Higher scores indicate better matches to the search query.
    /// Calculated based on query term matches in title and content.
    public let relevanceScore: Double
    
    /// Estimated reading time for the full article in minutes
    public var estimatedReadingTime: Int {
        return max(1, wordCount / 200) // ~200 words per minute
    }
    
    /// Whether this result is considered highly relevant
    public var isHighlyRelevant: Bool {
        return relevanceScore >= 1.5
    }
    
    internal init(
        title: String,
        snippet: String,
        pageId: Int,
        wordCount: Int,
        relevanceScore: Double
    ) {
        self.id = pageId
        self.title = title
        self.snippet = snippet
        self.pageId = pageId
        self.wordCount = wordCount
        self.relevanceScore = relevanceScore
    }
}
