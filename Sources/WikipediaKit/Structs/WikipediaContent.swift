//
//  WikipediaContent.swift
//  WikipediaKit
//
//  The whole article, and what it exists in besides this language.
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

    public let title: String

    /// The article as plain text, section headings included.
    public let text: String

    public let pageId: Int
    public let language: WikipediaLanguage
    public let url: URL

    public var characterCount: Int { text.count }

    /// Words, by whitespace — the figure a reading-time estimate needs.
    public var wordCount: Int {
        text.split(whereSeparator: \.isWhitespace).count
    }
}

/// One language an article also exists in.
public struct WikipediaTranslation: Sendable, Identifiable, Hashable {

    /// The language code, e.g. `de`.
    public let code: String

    /// The language's name in its own language, e.g. `Deutsch`.
    public let name: String

    /// The article's title in that language, which is often not a
    /// translation of the English one — `Alan Turing` is `ألان تورنج` in
    /// Arabic, and guessing the title from the code does not work.
    public let title: String

    public var id: String { code }

    /// Where to read it.
    public var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "\(code).wikipedia.org"
        components.path = "/wiki/\(title)"
        return components.url
    }
}
