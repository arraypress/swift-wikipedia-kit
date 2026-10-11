//
//  WikipediaContent.swift
//  WikipediaKit
//
//  Created by David Sherlock on 2026.
//

import Foundation

/// An article's full plain text.
///
/// Distinct from ``WikipediaArticle`` because the two come from different
/// endpoints with very different costs. A summary is the lead paragraph —
/// 448 characters for Alan Turing. The article is 63,928. Returning the
/// second where the first was asked for would make every lookup expensive;
/// returning the first while calling it the article, which is what happened
/// before this existed, hands back 0.7% of the page with nothing to say so.
public struct WikipediaContent: Sendable {

    /// Article title.
    public let title: String

    /// The article as plain text, section headings included.
    public let text: String

    /// Wikipedia page ID.
    public let pageId: Int

    /// Language edition this text is from.
    public let language: WikipediaLanguage

    /// Where to read the article.
    public let url: URL
}
