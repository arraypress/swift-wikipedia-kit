//
//  WikipediaArticle.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// A Wikipedia article's summary: its lead, description, thumbnail and page.
///
/// Reading figures (``estimatedReadingTime``, ``lengthCategory``) are in
/// `Extensions/WikipediaArticle+Reading.swift`.
public struct WikipediaArticle: Sendable, Identifiable {

    /// Unique identifier for the article (the page ID).
    public let id: Int

    /// Article title.
    public let title: String

    /// The article's lead — its summary, not the whole page (that is
    /// ``WikipediaKit/getContent(_:language:)``).
    public let extract: String

    /// Short description of the article.
    public let description: String?

    /// Article thumbnail image, if available.
    public let thumbnail: WikipediaImage?

    /// URL to the full article on Wikipedia.
    public let url: URL

    /// Wikipedia page ID.
    public let pageId: Int

    /// Language edition this article is from.
    public let language: WikipediaLanguage

    /// When the article was last modified.
    public let lastModified: Date?

    internal init(title: String, extract: String, description: String?, thumbnail: WikipediaImage?,
                  url: URL, pageId: Int, language: WikipediaLanguage, lastModified: Date?) {
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
