//
//  WikipediaArticle.swift
//  WikipediaKit
//
//  Created by David Sherlock on 03/08/2025.
//

import Foundation

// MARK: - Public Data Models

/// Represents a Wikipedia article with summary information.
///
/// Contains the essential information about a Wikipedia article including
/// title, extract, metadata, and reading time estimation.
public struct WikipediaArticle: Sendable, Identifiable {
    
    /// Unique identifier for the article
    public let id: Int
    
    /// Article title
    public let title: String
    
    /// Article summary/extract (first few paragraphs)
    public let extract: String
    
    /// Short description of the article
    public let description: String?
    
    /// Article thumbnail image, if available
    public let thumbnail: WikipediaImage?
    
    /// URL to the full article on Wikipedia
    public let url: URL
    
    /// Wikipedia page ID
    public let pageId: Int
    
    /// Language edition this article is from
    public let language: WikipediaLanguage
    
    /// When the article was last modified
    public let lastModified: Date?
    
    /// Estimated reading time in minutes based on extract length
    ///
    /// Calculated using ~200 words per minute reading speed.
    /// Useful for showing users how long the summary will take to read.
    public var estimatedReadingTime: Int {
        let words = extract.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        return max(1, words / 200) // Minimum 1 minute
    }
    
    /// Article length category based on extract word count
    ///
    /// Categorizes articles to help users understand content depth:
    /// - **Stub**: Very short articles (< 50 words)
    /// - **Short**: Brief articles (50-200 words)
    /// - **Medium**: Standard articles (200-500 words)
    /// - **Long**: Comprehensive articles (500-1000 words)
    /// - **Very Long**: Extensive articles (1000+ words)
    public var lengthCategory: ArticleLengthCategory {
        let words = extract.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        switch words {
        case 0..<50: return .stub
        case 50..<200: return .short
        case 200..<500: return .medium
        case 500..<1000: return .long
        default: return .veryLong
        }
    }
    
    /// Whether this article has a thumbnail image
    public var hasThumbnail: Bool {
        return thumbnail != nil
    }
    
    internal init(
        title: String,
        extract: String,
        description: String?,
        thumbnail: WikipediaImage?,
        url: URL,
        pageId: Int,
        language: WikipediaLanguage,
        lastModified: Date?
    ) {
        self.id = pageId
        self.title = title
        self.extract = extract
        self.description = description
        self.thumbnail = thumbnail
        self.url = url
        self.pageId = pageId
        self.language = language
        self.lastModified = lastModified
    }
    
}
